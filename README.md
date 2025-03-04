# Beacon

Steps to build a Phoenix umbrella project that uses Beacon:

1. Create an umbrella phoenix app:
    ```elixir
    mix phx.new --umbrella --install my_app
    ```
1. Add :beacon as a dependency to both apps in your umbrella project:
    ```elixir
      # Local:
      {:beacon, path: "../../../beacon"},
      # Or from GitHub:
      {:beacon, github: "beaconCMS/beacon"},
    ```
1. Add `Beacon.Repo` to `config :my_app, ecto_repos: [MyApp.Repo, Beacon.Repo]` in `config.exs`
1. Configure the Beacon Repo in your dev.exs and prod.exs:
    ```elixir
    config :beacon, Beacon.Repo,
      username: "postgres",
      password: "postgres",
      database: "my_app_beacon",
      hostname: "localhost",
      show_sensitive_data_on_connection_error: true,
      pool_size: 10
    ``` 
1. Create a `BeaconDataSource` module that implements `Beacon.DataSource.Behaviour`:
    ```elixir
    defmodule MyApp.BeaconDataSource do
      @behaviour Beacon.DataSource.Behaviour

      def live_data("my_site", "home", _params), do: %{vals: ["first", "second", "third"]}
      def live_data(_, _, _), do: %{}
    end
    ```
1. Add that DataSource to your config.exs:
    ```elixir
    config :beacon,
      data_source: MyApp.BeaconDataSource
    ```
1. Add a `:beacon` pipeline to your router:
    ```elixir
      pipeline :beacon do
        plug BeaconWeb.Plug
      end
    ```
1. Add a `BeaconWeb` scope to your router as shown below:
    ```elixir
      scope "/", BeaconWeb do
        pipe_through :browser
        pipe_through :beacon

        live_session :beacon, session: %{"beacon_site" => "my_site"} do
          live "/page/:path", PageLive, :path
        end
      end
    ```
1. Add some seeds to your seeds.exs:
    ```elixir
    alias Beacon.Components
    alias Beacon.Pages
    alias Beacon.Layouts
    alias Beacon.Stylesheets

    %{id: layout_id} =
      Layouts.create_layout!(%{
        site: "my_site",
        title: "Sample Home Page",
        meta_tags: %{"foo" => "bar"},
        stylesheet_urls: [],
        body: """
        <header>
          Header
        </header>
        <%= @inner_content %>

        <footer>
          Page Footer
        </footer>
        """
      })

    Pages.create_page!(%{
      path: "home",
      site: "my_site",
      layout_id: layout_id,
      template: """
      <main>
        <h2>Some Values:</h2>
        <ul>
          <%= for val <- live_data[:vals] do %>
            <%= my_component("sample_component", val: val) %>
          <% end %>
        </ul>
      </main>
      """
    })

    Components.create_component!(%{
      site: "my_site",
      name: "sample_component",
      body: """
      <li>
        <%= @val %>
      </li>
      """
    })

    Stylesheets.create_stylesheet!(%{
      site: "my_site",
      name: "sample_stylesheet",
      content: "body {cursor: zoom-in;}"
    })
    ```
1. `cd apps/my_app && mix ecto.reset && cd ../..`
1. `mix phx.server`
1. visit http://localhost:4000/page/home
1. Note:
  1. The Header and Footer from the layout
  1. The list element from the page
  1. The three components rendered with the live_data from your DataSource
  1. The zoom in cursor from the stylesheet

To enable Page Management UI:

1. Add the following to the top of your Router:
    ```elixir
    require BeaconWeb.PageManagement
    ```
1. Add the following scope to your Router:
    ```elixir
      scope "/page_management", BeaconWeb.PageManagement do
        pipe_through :browser

        BeaconWeb.PageManagement.routes()
      end
    ```
1. visit http://localhost:4000/page_management/pages
1. Edit the existing page or create a new page then click edit to go to the Page Editor (including version management)

To enable Page Management API:

1. Add the following to the top of your Router:
    ```elixir
    require BeaconWeb.PageManagementApi
    ```
1. Add the following scope to your Router:
    ```elixir
      scope "/page_management_api", BeaconWeb.PageManagementApi do
        pipe_through :api

        BeaconWeb.PageManagementApi.routes()
      end
    ```
1. Check out /lib/beacon_web/page_management_api.ex for currently available API endpoints.