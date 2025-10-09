defmodule ExAwsAthena.MixProject do
  use Mix.Project

  @version "0.1.0"
  @service "dynamo"
  @url "https://github.com/sreecodeslayer/ex_aws_#{@service}"
  @name __MODULE__ |> Module.split() |> Enum.take(2) |> Enum.join(".")

  def project do
    [
      app: :ex_aws_athena,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: @name,
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_aws, ">= 2.4"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:hackney, ">= 0.0.0", only: [:dev, :test]},
      {:jason, ">= 0.0.0", only: [:dev, :test]},
      {:sweet_xml, ">= 0.0.0", only: [:dev, :test]}
    ]
  end

  defp package do
    [
      description: "#{@name} service package",
      files: ["lib", "config", "mix.exs", "README*", "CHANGELOG*"],
      maintainers: ["Sreenadh TC"],
      licenses: ["MIT"],
      links: %{
        Changelog: "https://hexdocs.pm/ex_aws_athena/changelog.html",
        GitHub: @url
      }
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md",
        "README.md",
        "UPGRADE.md"
      ],
      main: "readme",
      source_url: @url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
