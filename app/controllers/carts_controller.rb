class CartsController < ApplicationController
  before_filter :authenticate_user!
end