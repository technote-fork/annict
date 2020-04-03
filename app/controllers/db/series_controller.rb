# frozen_string_literal: true

module Db
  class SeriesController < Db::ApplicationController
    before_action :authenticate_user!, only: %i(new create edit update hide destroy)

    def index
      @series_list = Series.without_deleted.order(id: :desc).page(params[:page]).per(100)
    end

    def new
      @series = Series.new
      authorize_db_resource @series
    end

    def create
      @series = Series.new(series_params)
      @series.user = current_user
      authorize_db_resource @series

      return render(:new) unless @series.valid?

      @series.save_and_create_activity!

      redirect_to db_series_list_path, notice: t("messages._common.created")
    end

    def edit
      @series = Series.without_deleted.find(params[:id])
      authorize @series, policy_class: DbResourcePolicy
    end

    def update
      @series = Series.without_deleted.find(params[:id])
      authorize_db_resource @series

      @series.attributes = series_params
      @series.user = current_user

      return render(:edit) unless @series.valid?

      @series.save_and_create_activity!

      redirect_to db_edit_series_path(@series), notice: t("messages._common.updated")
    end

    def destroy
      @series = Series.without_deleted.find(params[:id])
      authorize_db_resource @series

      @series.soft_delete

      redirect_back(
        fallback_location: db_series_list_path,
        notice: t("messages._common.deleted")
      )
    end

    def activities
      @series = Series.find(params[:id])
      @activities = @series.db_activities.order(id: :desc)
      @comment = @series.db_comments.new
    end

    private

    def series_params
      params.require(:series).permit(:name, :name_alter, :name_alter_en, :name_en)
    end
  end
end
