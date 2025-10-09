defmodule ExAws.Athena do
  alias ExAws.Operation.JSON
  import ExAws.Utils, only: [camelize: 1, camelize_keys: 2]

  @namespace "AmazonAthena"

  @moduledoc """
  Operations on AWS Athena

  http://docs.aws.amazon.com/athena/latest/APIReference/API_Operations.html
  """

  @doc """
  Starts a query execution and returns a unique ID representing that execution.

  Refer: https://docs.aws.amazon.com/athena/latest/APIReference/API_StartQueryExecution.html
  """
  @spec start_query_execution(
          query_string :: String.t(),
          result_configuration :: map(),
          opts :: keyword()
        ) :: JSON.t()
  def start_query_execution(query_string, result_configuration, _opts \\ []) do
    data = %{
      "ClientRequestToken" => random_string(64),
      "QueryString" => query_string,
      "ResultConfiguration" => camelize_keys(result_configuration, deep: true)
    }

    request(:start_query_execution, data)
  end

  defp request(op, data, opts \\ %{}) do
    operation = op |> to_string() |> camelize()

    JSON.new(
      :athena,
      Map.merge(
        %{
          data: Jason.encode!(data),
          headers: [
            {"x-amz-target", "#{@namespace}.#{operation}"},
            {"content-type", "application/x-amz-json-1.1"}
          ]
        },
        opts
      )
    )
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
