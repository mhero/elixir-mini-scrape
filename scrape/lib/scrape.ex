defmodule Scrape do
    @moduledoc """
    Documentation for Scrape.
    """

    @doc """
    Hello world.
    """
    use Application

    def start(_type, _args) do
        IO.puts "starting"

        parsed = (call |> parse)
        parsed_size = elem(parsed, 0) # we have multiple lists, this is it's size
        parsed_elements = elem(parsed, 1) # these are the lists

        IO.puts parsed_size
        Enum.at(parsed_elements, 0) |> job_details |> IO.inspect

        Task.start(fn -> :timer.sleep(1000); IO.puts("done sleeping") end)
    end
    
    def job_details(job_html) do
        { _, [ { _, job_type } ], _ } = job_html
        { _, _, [ { _, [ { _, url } ], details } ] } = job_html
        [ { _, [ _, { _, logo} ], _ }, name, { _, _, [ { _, _, [ _ | tags ] } ] }, _, _] = details
        {job_type, url, logo, tags_details tags }
    end

    def tags_details(tags_html) do
        Enum.reduce(
            tags_html, [], fn(tag, acc) -> 
                { _, _, [ _tag ] } = tag
                acc ++ [_tag]
            end
        )
    end

    def call do
        response =  "MPaVx1MKw6oPOWKq%2BjG4VhjzJ6Wq0%2Fzu7H2bN%2B2W21M%3D" |> Cipher.decrypt |> HTTPotion.get
        response.body
    end

    def parse(html) do
        parsed = Floki.find(html, "div.job")
        { Enum.count(parsed), parsed }
    end
end