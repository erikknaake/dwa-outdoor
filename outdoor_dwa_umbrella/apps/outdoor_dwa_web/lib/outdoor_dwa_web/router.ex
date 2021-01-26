defmodule OutdoorDwaWeb.Router do
  use OutdoorDwaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {OutdoorDwaWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug :put_root_layout, {OutdoorDwaWeb.LayoutView, "live_admin.html"}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :static do
    if Mix.env() in [:dev, :test] do
      plug Plug.Static,
        at: "/static",
        from: {:outdoor_dwa_web, "priv/static"}
    else
      plug Plug.Static,
        at: "/static",
        from: "apps/outdoor_dwa_web/priv/static"
    end
  end

  scope "/", OutdoorDwaWeb do
    pipe_through :browser

    live "/", HomeLive, :index
    live "/login", LoginLive, :index
    live "/logout", LogoutLive, :index
    live "/teams/tasks", TaskOverviewLive, :index
    live "/teams/location-tasks/:task_id", LocationTaskLive, :index
    live "/teams/practical-tasks/:task_id", PracticalTaskLive, :index
    live "/teams/projects", ProjectLive, :index
    live "/teams/ranking", TeamRankingsLive, :index
    live "/teams/statistics", TeamStatisticsLive, :index
    live "/teams/settings", TeamSettingsLive, :index
    live "/teams/tracks", TracksOverviewLive
    live "/registration", RegistrationLive, :index
    live "/register/user", RegistrateUserLive
    live "/register/team/:edition_id", RegistrateTeamLive, :index
    live "/editions", EditionOverviewLive, :index
    live "/editions/:edition_id", EditionsLive, :index
    live "/announcements", AnnouncementLive, :index

    scope "/admin", Admin, as: :admin do
      pipe_through [:admin]

      live "/", HomeLive, :index

      live "/appoint-admin", AppointAdminLive, :index

      live "/editions", EditionOverviewLive, :index
      live "/editions/:edition_id/edit", EditionFormLive, :edit
      live "/editions/create", EditionFormLive, :create
      live "/editions/:edition_id/agents", TravelAgentsLive, :index
      live "/editions/:edition_id/coorganisators", CoorganisatorLive, :index

      live "/practical-tasks", PracticalTaskOverviewLive, :index
      live "/practical-tasks/:practical_task_id/edit", PracticalTaskEditLive, :index
      live "/practical-tasks/create", PracticalTaskEditLive, :index, as: :practical_task_create

      live "/travel-questions", TravelQuestionOverviewLive, :index
      live "/travel-questions/:travel_question_id/edit", TravelQuestionEditLive, :index
      live "/travel-questions/create", TravelQuestionEditLive, :index, as: :travel_question_create

      live "/projects", ProjectOverviewLive, :index
      live "/projects/:project_id/edit", ProjectEditLive, :index
      live "/projects/create", ProjectEditLive, :index, as: :project_create
      live "/projects/reviews", ProjectReviewOverviewLive, :index
      live "/projects/reviews/:submission_id", ProjectReviewLive, :index

      live "/reviews", ReviewOverviewLive, :index
      live "/reviews/:submission_id", TaskReviewLive, :index

      live "/announcements", AnnouncementOverviewLive, :index
      live "/announcement/:announcement_id/edit", AnnouncementDetailsLive, :index
      live "/announcement/create", AnnouncementDetailsLive, :index, as: :announcement_create
    end

    scope "/static" do
      pipe_through :static
      get "/*path", ErrorController, :notfound
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", OutdoorDwaWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: OutdoorDwaWeb.Telemetry
    end
  end
end
