defmodule ExAws.Athena do
  alias ExAws.Operation.JSON

  @namespace "AmazonAthena"

  @moduledoc """
  Operations on AWS Athena

  http://docs.aws.amazon.com/athena/latest/APIReference/API_Operations.html
  """

  @spec start_query_execution(query :: String.t(), opts :: keyword()) :: JSON.t()
  def start_query_execution(query, opts \\ []) do
    body = %{
      "ClientRequestToken" => random_string(64),
      "QueryString" => query
    }

    request(op, data, opts)
  end

  defp request(op, data, opts \\ %{}) do
    operation =
      op
      |> Atom.to_string()
      |> Macro.camelize()

    JSON.new(
      :athena,
      Map.merge(
        %{
          data: data,
          headers: [
            {"x-amz-target", "#{@namespace}.#{operation}"},
            {"content-type", "application/x-amz-json-1.0"}
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
