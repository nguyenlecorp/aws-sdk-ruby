require 'set'

module Aws
  module Plugins
    # @api private
    class RetryErrors < Seahorse::Client::Plugin
      EQUAL_JITTER = ->(delay) { (delay / 2) + Kernel.rand(0..(delay / 2)) }
      FULL_JITTER = ->(delay) { Kernel.rand(0..delay) }
      NO_JITTER = ->(delay) { delay }

      JITTERS = {
        none: NO_JITTER,
        equal: EQUAL_JITTER,
        full: FULL_JITTER
      }

      JITTERS.default_proc = lambda { |h, k|
        raise KeyError,
              "#{k} is not a named jitter function. Must be one of #{h.keys}"
      }

      DEFAULT_BACKOFF = lambda do |c|
        delay = 2**c.retries * c.config.retry_base_delay
        if (c.config.retry_max_delay || 0) > 0
          delay = [delay, c.config.retry_max_delay].min
        end
        jitter = c.config.retry_jitter
        jitter = JITTERS[jitter] if jitter.is_a?(Symbol)
        delay = jitter.call(delay) if jitter
        Kernel.sleep(delay)
      end

      option(
        :retry_limit,
        default: 3,
        doc_type: Integer,
        docstring: <<-DOCS) do |cfg|
The maximum number of times to retry failed requests.  Only
~ 500 level server errors and certain ~ 400 level client errors
are retried.  Generally, these are throttling errors, data
checksum errors, networking errors, timeout errors, auth errors,
endpoint discovery, and errors from expired credentials.
This option is only used in the `legacy` retry mode.
        DOCS
        resolve_max_attempts(cfg)
      end

      option(
        :retry_max_delay,
        default: 0,
        doc_type: Integer,
        docstring: <<-DOCS)
The maximum number of seconds to delay between retries (0 for no limit)
used by the default backoff function. This option is only used in the
`legacy` retry mode.
        DOCS

      option(
        :retry_base_delay,
        default: 0.3,
        doc_type: Float,
        docstring: <<-DOCS)
The base delay in seconds used by the default backoff function. This option
is only used in the `legacy` retry mode.
        DOCS

      option(
        :retry_jitter,
        default: :none,
        doc_type: Symbol,
        docstring: <<-DOCS)
A delay randomiser function used by the default backoff function.
Some predefined functions can be referenced by name - :none, :equal, :full,
otherwise a Proc that takes and returns a number. This option is only used
in the `legacy` retry mode.

@see https://www.awsarchitectureblog.com/2015/03/backoff.html
        DOCS

      option(:retry_backoff, DEFAULT_BACKOFF)

      option(
        :retry_mode,
        default: 'legacy',
        doc_type: String,
        docstring: <<-DOCS) do |cfg|
Specifies which retry algorithm to use. Defaults to `legacy`
which uses exponential backoff for all retries. Other modes include
`standard` and `adaptive` which use a token bucket with variable backoff.
        DOCS
        resolve_retry_mode(cfg)
      end

      option(
        :max_attempts,
        default: 3,
        doc_type: Integer,
        docstring: <<-DOCS) do |cfg|
Specifies how many HTTP requests an SDK should make for a single
SDK operation invocation before giving up. Used in `standard` and
`adaptive` retry modes, and will also set `retry_limit` in `legacy` mode.
        DOCS
        resolve_max_attempts(cfg)
      end

      def self.resolve_retry_mode(cfg)
        value = ENV['AWS_RETRY_MODE'] ||
                Aws.shared_config.retry_mode(profile: cfg.profile) ||
                'legacy'
        # Raise if provided value is not one of the retry modes
        if value != 'legacy' && value != 'standard' && value != 'adaptive'
          raise ArgumentError,
                'Must provide either `legacy`, `standard`, or `adaptive` for '\
                'retry_mode profile option or for ENV[\'AWS_RETRY_MODE\']'
        end
        value
      end

      def self.resolve_max_attempts(cfg)
        value = ENV['AWS_MAX_ATTEMPTS'] ||
                Aws.shared_config.max_attempts(profile: cfg.profile) ||
                3
        # Raise if provided value is not a positive integer
        if !value.is_a?(Integer) || value <= 0
          raise ArgumentError,
                'Must provide a positive integer for max_attempts profile '\
                'option or for ENV[\'AWS_MAX_ATTEMPTS\']'
        end
        value
      end

      # @api private
      class ErrorInspector
        EXPIRED_CREDS = Set.new(
          [
            'InvalidClientTokenId',        # query services
            'UnrecognizedClientException', # json services
            'InvalidAccessKeyId',          # s3
            'AuthFailure',                 # ec2
            'InvalidIdentityToken',        # sts
            'ExpiredToken'                 # route53
          ]
        )

        THROTTLING_ERRORS = Set.new(
          [
            'Throttling',                             # query services
            'ThrottlingException',                    # json services
            'ThrottledException',                     # sns
            'RequestThrottled',                       # sqs
            'RequestThrottledException',              # generic service
            'ProvisionedThroughputExceededException', # dynamodb
            'TransactionInProgressException',         # dynamodb
            'RequestLimitExceeded',                   # ec2
            'BandwidthLimitExceeded',                 # cloud search
            'LimitExceededException',                 # kinesis
            'TooManyRequestsException',               # batch
            'PriorRequestNotComplete',                # route53
            'SlowDown',                               # s3
            'EC2ThrottledException'                   # ec2
          ]
        )

        CHECKSUM_ERRORS = Set.new(
          [
            'CRC32CheckFailed' # dynamodb
          ]
        )

        NETWORKING_ERRORS = Set.new(
          [
            'RequestTimeout',          # s3
            'RequestTimeoutException', # glacier
            'IDPCommunicationError'    # sts
          ]
        )

        def initialize(error, http_status_code)
          @error = error
          @name = extract_name(error)
          @http_status_code = http_status_code
        end

        def expired_credentials?
          !!(EXPIRED_CREDS.include?(@name) || @name.match(/expired/i))
        end

        def throttling_error?
          !!(THROTTLING_ERRORS.include?(@name) ||
            @name.match(/throttl/i) ||
            @http_status_code == 429)
        end

        def checksum?
          CHECKSUM_ERRORS.include?(@name) || @error.is_a?(Errors::ChecksumError)
        end

        def networking?
          @error.is_a?(Seahorse::Client::NetworkingError) ||
            @error.is_a?(Errors::NoSuchEndpointError) ||
            NETWORKING_ERRORS.include?(@name)
        end

        def server?
          (500..599).cover?(@http_status_code)
        end

        def endpoint_discovery?(context)
          return false unless context.operation.endpoint_discovery

          if @http_status_code == 421 ||
             extract_name(@error) == 'InvalidEndpointException'
            @error = Errors::EndpointDiscoveryError.new
          end

          # When endpoint discovery error occurs
          # evict the endpoint from cache
          if @error.is_a?(Errors::EndpointDiscoveryError)
            key = context.config.endpoint_cache.extract_key(context)
            context.config.endpoint_cache.delete(key)
            true
          else
            false
          end
        end

        def retryable?(context)
          (expired_credentials? && refreshable_credentials?(context)) ||
            throttling_error? ||
            checksum? ||
            networking? ||
            server? ||
            endpoint_discovery?(context)
        end

        private

        def refreshable_credentials?(context)
          context.config.credentials.respond_to?(:refresh!)
        end

        def extract_name(error)
          if error.is_a?(Errors::ServiceError)
            error.class.code
          else
            error.class.name.to_s
          end
        end
      end

      # @api private
      class TokenBucket
        SMOOTH = 0.8

        def initialize
          @fill_rate        = nil
          @max_capacity     = nil
          @current_capacity = nil
          @last_timestamp   = Time.new
          @measured_tx_rate = 0
          @enabled          = false
        end

        attr_reader :fill_rate
        attr_reader :max_capacity
        attr_reader :current_capacity
        attr_reader :last_timestamp
        attr_reader :measured_tx_rate
        attr_reader :enabled

        def acquire(amount)
          t = Time.now
          dt = t - @last_timestamp

          if dt != 0
            rate = amount / dt
            if @measured_tx_rate == 0
              @measured_tx_rate = rate
            else
              @measured_tx_rate = SMOOTH * rate + (1 - SMOOTH) * @measured_tx_rate
            end
          end

          # Don't delay the request if we're not enabled
          @last_timestamp = t
          return unless @enabled

          # Refill the bucket based on the amount of time elapsed
          # since the last acquisition
          fill_amount = dt * @fill_rate
          @current_capacity = min(@max_capacity, @current_capacity + fill_amount)

          # Next see if we have enough capacity for the requested amount
          if amount <= @current_capacity
            @current_capacity -= amount
          else
            sleep((amount - @current_capacity / @fill_rate))
            @current_capacity = 0
            @last_timestamp = Time.new
          end
        end

        def update_rate(new_rps)
          # Refill based on our current rate before we update to the
          # new fill rate
          t = Time.new
          fill_amount = (t - @last_timestamp) * @fill_rate
          @current_capacity = min(@max_capacity, @current_capacity + fill_amount)
          @last_timestamp = t

          # Now we can update our fill rate
          @fill_rate = new_rps
          @max_capacity = new_rps
          @current_capacity = min(@current_capacity, @max_capacity)
        end

        def enable
          return if @enabled

          @enabled = true
          update_rate(@measured_tx_rate)
          @current_capacity = @measured_tx_rate
        end
      end

      class Handler < Seahorse::Client::Handler
        INITIAL_RETRY_TOKENS = 500
        RETRY_COST = 5
        NO_RETRY_INCREMENT = 1
        TIMEOUT_RETRY_COST = 10

        BETA = 0.7
        SCALE_CONSTANT = 0.4

        def call(context)
          retry_mode = context.config.retry_mode
          max_attempts = context.config.max_attempts
          puts "retry mode: #{retry_mode}, max_attempts: #{max_attempts}"

          attempts = 0

          get_send_token if context.config.retry_mode == 'adaptive'
          response = @handler.call(context)
          request_bookkeeping(response)
          return response unless retryable?(response)

          attempts += 1
          return response if attempts >= MAX_ATTEMPTS

          return response unless has_retry_quota?(response)

          delay = exponential_backoff(attempts)
          sleep(delay)
        end

        private

        def get_send_token

        end

        def request_bookkeeping(response)
          if throttling_error?(response)
            bucket = TokenBucket.new
            bucket.enable

            # The fill rate is from the token bucket
            last_max_rate = bucket.max_capacity
            last_throttle_time = Time.new

            bucket.update_rate(bucket.max_capacity * BETA)
          end

          unless response.error
            dt = Time.now - last_throttle_time
            # k can be cached, it only changes when we get throttled,
            # it's shown inline here for simplicity
            k = ((last_max_rate * (1 - BETA)) / SCALE_CONSTANT)**(1.0 / 3)
            calculated_rate = ((SCALE_CONSTANT * (dt - k)))**3 + last_max_rate

            new_rate = min(calculated_rate, 1.2 * bucket.measured_tx_rate)

            bucket.update_rate(new_rate)
          end
        end

        def throttling_error?(response)
          status_code = response.context.http_response.status_code
          ErrorInspector.new(response.error, status_code).throttling_error?
        end
      end

      class LegacyHandler < Seahorse::Client::Handler

        def call(context)
          response = @handler.call(context)
          if response.error
            retry_if_possible(response)
          else
            response
          end
        end

        private

        def retry_if_possible(response)
          context = response.context
          error = error_for(response)
          if should_retry?(context, error)
            retry_request(context, error)
          else
            response
          end
        end

        def error_for(response)
          status_code = response.context.http_response.status_code
          ErrorInspector.new(response.error, status_code)
        end

        def retry_request(context, error)
          delay_retry(context)
          context.retries += 1
          context.config.credentials.refresh! if error.expired_credentials?
          context.http_request.body.rewind
          context.http_response.reset
          call(context)
        end

        def delay_retry(context)
          context.config.retry_backoff.call(context)
        end

        def should_retry?(context, error)
          error.retryable?(context) &&
            context.retries < retry_limit(context) &&
            response_truncatable?(context)
        end

        def retry_limit(context)
          context.config.retry_limit
        end

        def response_truncatable?(context)
          context.http_response.body.respond_to?(:truncate)
        end
      end

      def add_handlers(handlers, config)
        if config.retry_mode == 'legacy'
          if config.retry_limit > 0
            handlers.add(LegacyHandler, step: :sign, priority: 99)
          end
        else
          handlers.add(Handler, step: :sign, priority: 99)
        end
      end
    end
  end
end
