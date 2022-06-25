# frozen_string_literal: true

class GamesController < ApplicationController
  before_action :authenticate_user!

  def index
    @conf = YAML.safe_load(File.read('config.yaml'))
  end
end
