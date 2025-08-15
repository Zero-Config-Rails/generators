class RailsAppController < ApplicationController
  def new
    initialize_form_options
  end

  def create
    # Build the Rails command based on selected options
    @generated_command = build_rails_command(params)

    # Debug logging
    Rails.logger.info "Generated command: #{@generated_command}"

    # Re-initialize the form options for the view
    initialize_form_options

    render :new
  end

  private

  def initialize_form_options
    @rails_versions = [
      [
        "edge (Gemfile pointing to the main branch on the Rails repository)",
        "edge"
      ],
      [
        "main (Gemfile pointing to the main branch on the Rails repository)",
        "main"
      ],
      %w[8.0.1 8.0.1],
      %w[7.2.1 7.2.1],
      %w[7.2.0 7.2.0],
      %w[7.1.4 7.1.4],
      %w[7.1.3.4 7.1.3.4],
      %w[7.1.3 7.1.3],
      %w[7.1.2 7.1.2],
      %w[7.1.1 7.1.1],
      %w[7.1.0 7.1.0],
      %w[7.0.8.1 7.0.8.1],
      %w[6.1.7.8 6.1.7.8],
      %w[6.0.6.1 6.0.6.1],
      %w[5.2.8.1 5.2.8.1],
      %w[5.1.7 5.1.7],
      %w[5.0.7.2 5.0.7.2]
    ]

    @databases = [
      ["SQLite3 (Default)", "sqlite3"],
      %w[PostgreSQL postgresql],
      %w[MySQL mysql],
      ["SQL Server", "sqlserver"],
      %w[Oracle oracle],
      %w[Trilogy trilogy],
      %w[JDBC jdbc],
      ["JDBC MySQL", "jdbc-mysql"],
      ["JDBC SQLite3", "jdbc-sqlite3"],
      ["JDBC PostgreSQL", "jdbc-postgresql"]
    ]

    @javascript_options = [
      ["Importmap (Default)", "importmap"],
      %w[Bun bun],
      %w[Webpack webpack],
      %w[ESbuild esbuild],
      %w[Rollup rollup]
    ]

    @css_options = [
      %w[Tailwind tailwind],
      %w[Bootstrap bootstrap],
      %w[Bulma bulma],
      %w[PostCSS postcss],
      %w[Sass sass]
    ]

    @asset_pipeline_options = [
      ["Sprockets (Default)", "sprockets"],
      %w[Propshaft propshaft]
    ]
  end

  private

  def build_rails_command(params)
    command = "rails new #{params[:app_name]}"

    # Add Rails version if specified
    if params[:rails_version].present? && params[:rails_version] != "8.0.1"
      command += " --rails-version=#{params[:rails_version]}"
    end

    # Add database option if not default
    if params[:database].present? && params[:database] != "sqlite3"
      command += " --database=#{params[:database]}"
    end

    # Add JavaScript option if not default
    if params[:javascript].present? && params[:javascript] != "importmap"
      command += " --javascript=#{params[:javascript]}"
    end

    # Add CSS option if not default
    if params[:css].present? && params[:css] != "tailwind"
      command += " --css=#{params[:css]}"
    end

    # Add asset pipeline option if not default
    if params[:asset_pipeline].present? &&
         params[:asset_pipeline] != "sprockets"
      command += " --asset-pipeline=#{params[:asset_pipeline]}"
    end

    # Add boolean flags
    command += " --api" if params[:api_only] == "1"
    command += " --skip-javascript" if params[:skip_javascript] == "1"
    command += " --skip-hotwire" if params[:skip_hotwire] == "1"
    command += " --skip-jbuilder" if params[:skip_jbuilder] == "1"
    command += " --skip-bootsnap" if params[:skip_bootsnap] == "1"
    command += " --skip-dev-gems" if params[:skip_dev_gems] == "1"
    command += " --skip-bundle" if params[:skip_bundle] == "1"
    command += " --skip-test" if params[:skip_test] == "1"
    command += " --skip-system-test" if params[:skip_system_test] == "1"
    command += " --skip-git" if params[:skip_git] == "1"
    command += " --skip-docker" if params[:skip_docker] == "1"
    command += " --skip-keeps" if params[:skip_keeps] == "1"
    command += " --skip-action-mailer" if params[:skip_action_mailer] == "1"
    command += " --skip-action-mailbox" if params[:skip_action_mailbox] == "1"
    command += " --skip-action-text" if params[:skip_action_text] == "1"
    command += " --skip-active-record" if params[:skip_active_record] == "1"
    command += " --skip-active-job" if params[:skip_active_job] == "1"
    command += " --skip-active-storage" if params[:skip_active_storage] == "1"
    command += " --skip-action-cable" if params[:skip_action_cable] == "1"
    command += " --skip-thruster" if params[:skip_thruster] == "1"
    command += " --skip-rubocop" if params[:skip_rubocop] == "1"
    command += " --skip-brakeman" if params[:skip_brakeman] == "1"
    command += " --skip-github-ci" if params[:skip_github_ci] == "1"
    command += " --skip-kamal" if params[:skip_kamal] == "1"
    command += " --skip-solid-cache" if params[:skip_solid_cache] == "1"

    command
  end
end
