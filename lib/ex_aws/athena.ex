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

  `opts` are camelized and sent with the request — `work_group` and
  `query_execution_context` among them. `QueryString`, `ResultConfiguration`
  and `ClientRequestToken` are applied after, so they cannot be overridden.

  Refer: https://docs.aws.amazon.com/athena/latest/APIReference/API_StartQueryExecution.html
  """
  @spec start_query_execution(
          query_string :: String.t(),
          result_configuration :: map(),
          opts :: keyword()
        ) :: JSON.t()
  def start_query_execution(query_string, result_configuration, opts \\ []) do
    data =
      opts
      |> normalize_opts()
      |> Map.merge(%{
        "ClientRequestToken" => random_string(64),
        "QueryString" => query_string,
        "ResultConfiguration" => camelize_keys(result_configuration, deep: true)
      })

    request(:start_query_execution, data)
  end

  @doc """
  Returns information about a single execution of a query.

  Refer: https://docs.aws.amazon.com/athena/latest/APIReference/API_GetQueryExecution.html
  """
  @spec get_query_execution(query_execution_id :: String.t(), opts :: keyword()) :: JSON.t()
  def get_query_execution(query_execution_id, opts \\ []) do
    data =
      opts
      |> normalize_opts()
      |> Map.put("QueryExecutionId", query_execution_id)

    request(:get_query_execution, data)
  end

  @doc """
  Returns the results of a single query execution.

  `opts` are camelized and sent with the request. `NextToken` is how a result
  set larger than one page is read — Athena caps a page at 1000 rows, and the
  first page spends one of them on the column header:

      ExAws.Athena.get_query_results(id, next_token: token, max_results: 1000)

  Refer: https://docs.aws.amazon.com/athena/latest/APIReference/API_GetQueryResults.html
  """
  @spec get_query_results(query_execution_id :: String.t(), opts :: keyword()) :: JSON.t()
  def get_query_results(query_execution_id, opts \\ []) do
    data =
      opts
      |> normalize_opts()
      |> Map.put("QueryExecutionId", query_execution_id)

    request(:get_query_results, data)
  end

  # Accepts a keyword list or a map, so a caller need not care which. Keys are
  # camelized to the names the API uses: `next_token:` becomes `"NextToken"`.
  defp normalize_opts(opts) do
    opts
    |> Map.new()
    |> camelize_keys(deep: true)
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
