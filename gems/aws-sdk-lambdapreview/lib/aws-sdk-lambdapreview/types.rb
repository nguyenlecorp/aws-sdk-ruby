# WARNING ABOUT GENERATED CODE
#
# This file is generated. See the contributing for info on making contributions:
# https://github.com/aws/aws-sdk-ruby/blob/master/CONTRIBUTING.md
#
# WARNING ABOUT GENERATED CODE

module Aws
  module LambdaPreview
    module Types

      # @note When making an API call, pass AddEventSourceRequest
      #   data as a hash:
      #
      #       {
      #         event_source: "String", # required
      #         function_name: "FunctionName", # required
      #         role: "RoleArn", # required
      #         batch_size: 1,
      #         parameters: {
      #           "String" => "String",
      #         },
      #       }
      class AddEventSourceRequest < Struct.new(
        :event_source,
        :function_name,
        :role,
        :batch_size,
        :parameters)

        include Aws::Structure

        # @!attribute [rw] event_source
        #   The Amazon Resource Name (ARN) of the Amazon Kinesis stream that is
        #   the event source. Any record added to this stream causes AWS Lambda
        #   to invoke your Lambda function. AWS Lambda POSTs the Amazon Kinesis
        #   event, containing records, to your Lambda function as JSON.
        #   @return [String]

        # @!attribute [rw] function_name
        #   The Lambda function to invoke when AWS Lambda detects an event on
        #   the stream.
        #   @return [String]

        # @!attribute [rw] role
        #   The ARN of the IAM role (invocation role) that AWS Lambda can assume
        #   to read from the stream and invoke the function.
        #   @return [String]

        # @!attribute [rw] batch_size
        #   The largest number of records that AWS Lambda will give to your
        #   function in a single event. The default is 100 records.
        #   @return [Integer]

        # @!attribute [rw] parameters
        #   A map (key-value pairs) defining the configuration for AWS Lambda to
        #   use when reading the event source. Currently, AWS Lambda supports
        #   only the `InitialPositionInStream` key. The valid values are:
        #   \"TRIM\_HORIZON\" and \"LATEST\". The default value is
        #   \"TRIM\_HORIZON\". For more information, go to
        #   [ShardIteratorType][1] in the Amazon Kinesis Service API Reference.
        #
        #
        #
        #   [1]: http://docs.aws.amazon.com/kinesis/latest/APIReference/API_GetShardIterator.html#Kinesis-GetShardIterator-request-ShardIteratorType
        #   @return [Hash<String,String>]

      end

      # @note When making an API call, pass DeleteFunctionRequest
      #   data as a hash:
      #
      #       {
      #         function_name: "FunctionName", # required
      #       }
      class DeleteFunctionRequest < Struct.new(
        :function_name)

        include Aws::Structure

        # @!attribute [rw] function_name
        #   The Lambda function to delete.
        #   @return [String]

      end

      # Describes mapping between an Amazon Kinesis stream and a Lambda
      # function.
      class EventSourceConfiguration < Struct.new(
        :uuid,
        :batch_size,
        :event_source,
        :function_name,
        :parameters,
        :role,
        :last_modified,
        :is_active,
        :status)

        include Aws::Structure

        # @!attribute [rw] uuid
        #   The AWS Lambda assigned opaque identifier for the mapping.
        #   @return [String]

        # @!attribute [rw] batch_size
        #   The largest number of records that AWS Lambda will POST in the
        #   invocation request to your function.
        #   @return [Integer]

        # @!attribute [rw] event_source
        #   The Amazon Resource Name (ARN) of the Amazon Kinesis stream that is
        #   the source of events.
        #   @return [String]

        # @!attribute [rw] function_name
        #   The Lambda function to invoke when AWS Lambda detects an event on
        #   the stream.
        #   @return [String]

        # @!attribute [rw] parameters
        #   The map (key-value pairs) defining the configuration for AWS Lambda
        #   to use when reading the event source.
        #   @return [Hash<String,String>]

        # @!attribute [rw] role
        #   The ARN of the IAM role (invocation role) that AWS Lambda can assume
        #   to read from the stream and invoke the function.
        #   @return [String]

        # @!attribute [rw] last_modified
        #   The UTC time string indicating the last time the event mapping was
        #   updated.
        #   @return [Time]

        # @!attribute [rw] is_active
        #   Indicates whether the event source mapping is currently honored.
        #   Events are only processes if IsActive is true.
        #   @return [Boolean]

        # @!attribute [rw] status
        #   The description of the health of the event source mapping. Valid
        #   values are: \"PENDING\", \"OK\", and \"PROBLEM:*message*\".
        #   Initially this staus is \"PENDING\". When AWS Lambda begins
        #   processing events, it changes the status to \"OK\".
        #   @return [String]

      end

      # The object for the Lambda function location.
      class FunctionCodeLocation < Struct.new(
        :repository_type,
        :location)

        include Aws::Structure

        # @!attribute [rw] repository_type
        #   The repository from which you can download the function.
        #   @return [String]

        # @!attribute [rw] location
        #   The presigned URL you can use to download the function\'s .zip file
        #   that you previously uploaded. The URL is valid for up to 10 minutes.
        #   @return [String]

      end

      # A complex type that describes function metadata.
      class FunctionConfiguration < Struct.new(
        :function_name,
        :function_arn,
        :configuration_id,
        :runtime,
        :role,
        :handler,
        :mode,
        :code_size,
        :description,
        :timeout,
        :memory_size,
        :last_modified)

        include Aws::Structure

        # @!attribute [rw] function_name
        #   The name of the function.
        #   @return [String]

        # @!attribute [rw] function_arn
        #   The Amazon Resource Name (ARN) assigned to the function.
        #   @return [String]

        # @!attribute [rw] configuration_id
        #   A Lambda-assigned unique identifier for the current function code
        #   and related configuration.
        #   @return [String]

        # @!attribute [rw] runtime
        #   The runtime environment for the Lambda function.
        #   @return [String]

        # @!attribute [rw] role
        #   The Amazon Resource Name (ARN) of the IAM role that Lambda assumes
        #   when it executes your function to access any other Amazon Web
        #   Services (AWS) resources.
        #   @return [String]

        # @!attribute [rw] handler
        #   The function Lambda calls to begin executing your function.
        #   @return [String]

        # @!attribute [rw] mode
        #   The type of the Lambda function you uploaded.
        #   @return [String]

        # @!attribute [rw] code_size
        #   The size, in bytes, of the function .zip file you uploaded.
        #   @return [Integer]

        # @!attribute [rw] description
        #   The user-provided description.
        #   @return [String]

        # @!attribute [rw] timeout
        #   The function execution time at which Lambda should terminate the
        #   function. Because the execution time has cost implications, we
        #   recommend you set this value based on your expected execution time.
        #   The default is 3 seconds.
        #   @return [Integer]

        # @!attribute [rw] memory_size
        #   The memory size, in MB, you configured for the function. Must be a
        #   multiple of 64 MB.
        #   @return [Integer]

        # @!attribute [rw] last_modified
        #   The timestamp of the last time you updated the function.
        #   @return [Time]

      end

      # @note When making an API call, pass GetEventSourceRequest
      #   data as a hash:
      #
      #       {
      #         uuid: "String", # required
      #       }
      class GetEventSourceRequest < Struct.new(
        :uuid)

        include Aws::Structure

        # @!attribute [rw] uuid
        #   The AWS Lambda assigned ID of the event source mapping.
        #   @return [String]

      end

      # @note When making an API call, pass GetFunctionConfigurationRequest
      #   data as a hash:
      #
      #       {
      #         function_name: "FunctionName", # required
      #       }
      class GetFunctionConfigurationRequest < Struct.new(
        :function_name)

        include Aws::Structure

        # @!attribute [rw] function_name
        #   The name of the Lambda function for which you want to retrieve the
        #   configuration information.
        #   @return [String]

      end

      # @note When making an API call, pass GetFunctionRequest
      #   data as a hash:
      #
      #       {
      #         function_name: "FunctionName", # required
      #       }
      class GetFunctionRequest < Struct.new(
        :function_name)

        include Aws::Structure

        # @!attribute [rw] function_name
        #   The Lambda function name.
        #   @return [String]

      end

      # This response contains the object for AWS Lambda function location
      # (see API\_FunctionCodeLocation
      class GetFunctionResponse < Struct.new(
        :configuration,
        :code)

        include Aws::Structure

        # @!attribute [rw] configuration
        #   A complex type that describes function metadata.
        #   @return [Types::FunctionConfiguration]

        # @!attribute [rw] code
        #   The object for the Lambda function location.
        #   @return [Types::FunctionCodeLocation]

      end

      # @note When making an API call, pass InvokeAsyncRequest
      #   data as a hash:
      #
      #       {
      #         function_name: "FunctionName", # required
      #         invoke_args: "data", # required
      #       }
      class InvokeAsyncRequest < Struct.new(
        :function_name,
        :invoke_args)

        include Aws::Structure

        # @!attribute [rw] function_name
        #   The Lambda function name.
        #   @return [String]

        # @!attribute [rw] invoke_args
        #   JSON that you want to provide to your Lambda function as input.
        #   @return [IO]

      end

      # Upon success, it returns empty response. Otherwise, throws an
      # exception.
      class InvokeAsyncResponse < Struct.new(
        :status)

        include Aws::Structure

        # @!attribute [rw] status
        #   It will be 202 upon success.
        #   @return [Integer]

      end

      # @note When making an API call, pass ListEventSourcesRequest
      #   data as a hash:
      #
      #       {
      #         event_source_arn: "String",
      #         function_name: "FunctionName",
      #         marker: "String",
      #         max_items: 1,
      #       }
      class ListEventSourcesRequest < Struct.new(
        :event_source_arn,
        :function_name,
        :marker,
        :max_items)

        include Aws::Structure

        # @!attribute [rw] event_source_arn
        #   The Amazon Resource Name (ARN) of the Amazon Kinesis stream.
        #   @return [String]

        # @!attribute [rw] function_name
        #   The name of the AWS Lambda function.
        #   @return [String]

        # @!attribute [rw] marker
        #   Optional string. An opaque pagination token returned from a previous
        #   `ListEventSources` operation. If present, specifies to continue the
        #   list from where the returning call left off.
        #   @return [String]

        # @!attribute [rw] max_items
        #   Optional integer. Specifies the maximum number of event sources to
        #   return in response. This value must be greater than 0.
        #   @return [Integer]

      end

      # Contains a list of event sources (see API\_EventSourceConfiguration)
      class ListEventSourcesResponse < Struct.new(
        :next_marker,
        :event_sources)

        include Aws::Structure

        # @!attribute [rw] next_marker
        #   A string, present if there are more event source mappings.
        #   @return [String]

        # @!attribute [rw] event_sources
        #   An arrary of `EventSourceConfiguration` objects.
        #   @return [Array<Types::EventSourceConfiguration>]

      end

      # @note When making an API call, pass ListFunctionsRequest
      #   data as a hash:
      #
      #       {
      #         marker: "String",
      #         max_items: 1,
      #       }
      class ListFunctionsRequest < Struct.new(
        :marker,
        :max_items)

        include Aws::Structure

        # @!attribute [rw] marker
        #   Optional string. An opaque pagination token returned from a previous
        #   `ListFunctions` operation. If present, indicates where to continue
        #   the listing.
        #   @return [String]

        # @!attribute [rw] max_items
        #   Optional integer. Specifies the maximum number of AWS Lambda
        #   functions to return in response. This parameter value must be
        #   greater than 0.
        #   @return [Integer]

      end

      # Contains a list of AWS Lambda function configurations (see
      # API\_FunctionConfiguration.
      class ListFunctionsResponse < Struct.new(
        :next_marker,
        :functions)

        include Aws::Structure

        # @!attribute [rw] next_marker
        #   A string, present if there are more functions.
        #   @return [String]

        # @!attribute [rw] functions
        #   A list of Lambda functions.
        #   @return [Array<Types::FunctionConfiguration>]

      end

      # @note When making an API call, pass RemoveEventSourceRequest
      #   data as a hash:
      #
      #       {
      #         uuid: "String", # required
      #       }
      class RemoveEventSourceRequest < Struct.new(
        :uuid)

        include Aws::Structure

        # @!attribute [rw] uuid
        #   The event source mapping ID.
        #   @return [String]

      end

      # @note When making an API call, pass UpdateFunctionConfigurationRequest
      #   data as a hash:
      #
      #       {
      #         function_name: "FunctionName", # required
      #         role: "RoleArn",
      #         handler: "Handler",
      #         description: "Description",
      #         timeout: 1,
      #         memory_size: 1,
      #       }
      class UpdateFunctionConfigurationRequest < Struct.new(
        :function_name,
        :role,
        :handler,
        :description,
        :timeout,
        :memory_size)

        include Aws::Structure

        # @!attribute [rw] function_name
        #   The name of the Lambda function.
        #   @return [String]

        # @!attribute [rw] role
        #   The Amazon Resource Name (ARN) of the IAM role that Lambda will
        #   assume when it executes your function.
        #   @return [String]

        # @!attribute [rw] handler
        #   The function that Lambda calls to begin executing your function. For
        #   Node.js, it is the *module-name.export* value in your function.
        #   @return [String]

        # @!attribute [rw] description
        #   A short user-defined function description. Lambda does not use this
        #   value. Assign a meaningful description as you see fit.
        #   @return [String]

        # @!attribute [rw] timeout
        #   The function execution time at which Lambda should terminate the
        #   function. Because the execution time has cost implications, we
        #   recommend you set this value based on your expected execution time.
        #   The default is 3 seconds.
        #   @return [Integer]

        # @!attribute [rw] memory_size
        #   The amount of memory, in MB, your Lambda function is given. Lambda
        #   uses this memory size to infer the amount of CPU allocated to your
        #   function. Your function use-case determines your CPU and memory
        #   requirements. For example, a database operation might need less
        #   memory compared to an image processing function. The default value
        #   is 128 MB. The value must be a multiple of 64 MB.
        #   @return [Integer]

      end

      # @note When making an API call, pass UploadFunctionRequest
      #   data as a hash:
      #
      #       {
      #         function_name: "FunctionName", # required
      #         function_zip: "data", # required
      #         runtime: "nodejs", # required, accepts nodejs
      #         role: "RoleArn", # required
      #         handler: "Handler", # required
      #         mode: "event", # required, accepts event
      #         description: "Description",
      #         timeout: 1,
      #         memory_size: 1,
      #       }
      class UploadFunctionRequest < Struct.new(
        :function_name,
        :function_zip,
        :runtime,
        :role,
        :handler,
        :mode,
        :description,
        :timeout,
        :memory_size)

        include Aws::Structure

        # @!attribute [rw] function_name
        #   The name you want to assign to the function you are uploading. The
        #   function names appear in the console and are returned in the
        #   ListFunctions API. Function names are used to specify functions to
        #   other AWS Lambda APIs, such as InvokeAsync.
        #   @return [String]

        # @!attribute [rw] function_zip
        #   A .zip file containing your packaged source code. For more
        #   information about creating a .zip file, go to [AWS LambdaL How it
        #   Works][1] in the AWS Lambda Developer Guide.
        #
        #
        #
        #   [1]: http://docs.aws.amazon.com/lambda/latest/dg/walkthrough-custom-events.html
        #   @return [IO]

        # @!attribute [rw] runtime
        #   The runtime environment for the Lambda function you are uploading.
        #   Currently, Lambda supports only \"nodejs\" as the runtime.
        #   @return [String]

        # @!attribute [rw] role
        #   The Amazon Resource Name (ARN) of the IAM role that Lambda assumes
        #   when it executes your function to access any other Amazon Web
        #   Services (AWS) resources.
        #   @return [String]

        # @!attribute [rw] handler
        #   The function that Lambda calls to begin execution. For Node.js, it
        #   is the *module-name*.*export* value in your function.
        #   @return [String]

        # @!attribute [rw] mode
        #   How the Lambda function will be invoked. Lambda supports only the
        #   \"event\" mode.
        #   @return [String]

        # @!attribute [rw] description
        #   A short, user-defined function description. Lambda does not use this
        #   value. Assign a meaningful description as you see fit.
        #   @return [String]

        # @!attribute [rw] timeout
        #   The function execution time at which Lambda should terminate the
        #   function. Because the execution time has cost implications, we
        #   recommend you set this value based on your expected execution time.
        #   The default is 3 seconds.
        #   @return [Integer]

        # @!attribute [rw] memory_size
        #   The amount of memory, in MB, your Lambda function is given. Lambda
        #   uses this memory size to infer the amount of CPU allocated to your
        #   function. Your function use-case determines your CPU and memory
        #   requirements. For example, database operation might need less memory
        #   compared to image processing function. The default value is 128 MB.
        #   The value must be a multiple of 64 MB.
        #   @return [Integer]

      end

    end
  end
end