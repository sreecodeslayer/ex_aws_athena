defmodule ExAws.AthenaTest do
  use ExUnit.Case, async: true

  # Every assertion reads the request body, because that is where the bug was:
  # the functions took an `opts` argument and dropped it, so a caller passing
  # `next_token:` got a request without one and no error to say so.
  defp body(%ExAws.Operation.JSON{data: data}), do: Jason.decode!(data)

  describe "get_query_results/2" do
    test "sends the execution id" do
      assert %{"QueryExecutionId" => "q-1"} = body(ExAws.Athena.get_query_results("q-1"))
    end

    test "sends a next token, which is what reads a result set past the first page" do
      assert %{"NextToken" => "page-2", "QueryExecutionId" => "q-1"} =
               body(ExAws.Athena.get_query_results("q-1", next_token: "page-2"))
    end

    test "sends max results" do
      assert %{"MaxResults" => 500} =
               body(ExAws.Athena.get_query_results("q-1", max_results: 500))
    end

    test "accepts a map as readily as a keyword list" do
      assert %{"NextToken" => "page-2"} =
               body(ExAws.Athena.get_query_results("q-1", %{next_token: "page-2"}))
    end

    test "sends only the id when there are no options" do
      assert body(ExAws.Athena.get_query_results("q-1")) == %{"QueryExecutionId" => "q-1"}
    end

    test "targets GetQueryResults" do
      %ExAws.Operation.JSON{headers: headers} = ExAws.Athena.get_query_results("q-1")
      assert {_, "AmazonAthena.GetQueryResults"} = List.keyfind(headers, "x-amz-target", 0)
    end
  end

  describe "get_query_execution/2" do
    test "sends the execution id" do
      assert %{"QueryExecutionId" => "q-1"} = body(ExAws.Athena.get_query_execution("q-1"))
    end
  end

  describe "start_query_execution/3" do
    test "sends the query and its result configuration" do
      data = body(ExAws.Athena.start_query_execution("SELECT 1", %{output_location: "s3://b/"}))

      assert data["QueryString"] == "SELECT 1"
      assert data["ResultConfiguration"] == %{"OutputLocation" => "s3://b/"}
      assert is_binary(data["ClientRequestToken"])
    end

    test "sends a work group" do
      data =
        body(
          ExAws.Athena.start_query_execution("SELECT 1", %{output_location: "s3://b/"},
            work_group: "analytics"
          )
        )

      assert data["WorkGroup"] == "analytics"
    end

    test "options cannot override the query or its result configuration" do
      data =
        body(
          ExAws.Athena.start_query_execution("SELECT 1", %{output_location: "s3://b/"},
            query_string: "DROP TABLE t",
            result_configuration: %{output_location: "s3://elsewhere/"}
          )
        )

      assert data["QueryString"] == "SELECT 1"
      assert data["ResultConfiguration"] == %{"OutputLocation" => "s3://b/"}
    end

    test "each call carries its own request token" do
      one = body(ExAws.Athena.start_query_execution("SELECT 1", %{output_location: "s3://b/"}))
      two = body(ExAws.Athena.start_query_execution("SELECT 1", %{output_location: "s3://b/"}))

      refute one["ClientRequestToken"] == two["ClientRequestToken"]
    end
  end
end
