class Api::V1::UsersController < ApplicationController

  def index
    @users = User.all
    render json: @users
  end

  def create_helper(attribute, parameter)
    if !!@user[attribute]
      if @user[attribute] < params[:"#{parameter}"]
        @user.update("#{attribute}": params[:"#{parameter}"])
      end
    else
      @user.update("#{attribute}": params[:"#{parameter}"])
    end
  end

  def update_or_create
    @user = User.find_or_create_by(username: params[:username])

    create_helper('top_score', 'total_score')
    create_helper('most_snowmen', 'snowmen_score')

    if !!@user.game_count
      @user.update(game_count: (@user.game_count + 1))
    else
      @user.update(game_count: 1)
    end

    if !!@user.total_snowmen
      @user.update(total_snowmen: (@user.total_snowmen + params[:snowmen_score]))
    else
      @user.update(total_snowmen: params[:snowmen_score])
    end

    if @user.save
      render json: @user
    else
      render json: {errors: @user.errors.full_messages}, status: 422
    end
  end

  def rank_helper(attribute)
    users = User.all.sort_by { |user| user[`#{attribute}`]}
    username = params[:username]
    users.each_with_index do |user, i|
      if user.username == username
        user_rank = i
      end
    end
    return user_rank
  end

  def rank
    render json: {
      top_score_rank: rank_helper('top_score'),
      most_snowmen_rank: rank_helper('most_snowmen'),
      total_snowmen_rank: rank_helper('total_snowmen')
    }
  end



  def top_scorers
    @users = User.all.sort_by { |user| user.top_score}[0..2].reverse
    render json: @users
  end

  def top_slayers
    @users = User.all.sort_by { |user| user.most_snowmen}[0..2].reverse
    render json: @users
  end

  def genocidal_maniacs
    @users = User.all.sort_by { |user| user.total_snowmen}[0..2].reverse
    render json: @users
  end

  private
  def user_params
    params.permit(:username, :top_score, :most_snowmen, :total_snowmen, :game_count, :total_score, :snowmen_score)
  end

end
