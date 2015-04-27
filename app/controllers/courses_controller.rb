class CoursesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_course, only: [:show, :edit, :update, :destroy]
  before_action :set_tags, only: [:index, :search]

  check_authorization
  load_and_authorize_resource

  rescue_from CanCan::AccessDenied do |exception|
    render text: "You are not authorized"
  end 

  # GET /courses
  def index
    @courses = Course.page(params[:page])
    @tags = Course.tag_counts_on(:tags)
  end

  # GET /courses/1
  def show
    @course_sorter = CourseSorter.new(@course)
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses
  def create
    @course = Course.new(course_params)

    if @course.save
      unless params[:file_attachments].nil?
        params[:file_attachments][:file].each do |a|
          @file_atachment = @course.file_attachments.create(:file => a, :course_id => @course.id)
        end
      end
      redirect_to @course, notice: 'Course was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /courses/1
  def update
    if @course.update(course_params)
      unless params[:file_attachments].nil?
        params[:file_attachments][:file].each do |a|
          @file_atachment = @course.file_attachments.create(:file => a, :course_id => @course.id)
        end
      end
      redirect_to @course, notice: 'Course was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /courses/1
  def destroy
    @course.destroy
    redirect_to courses_url, notice: 'Course was successfully destroyed.'
  end

  def search
    if params[:tag]
      @courses = Course.tagged_with(params[:tag]).page
    else
      @courses = Course.includes([:file_attachments]).where("name ilike ?", "%#{params[:course][:query]}%").page(params[:page])
    end
    render :index
  end

  private

  def set_tags
    @tags = ActsAsTaggableOn::Tag.most_used(10)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_course
    @course = Course.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def course_params
    params.require(:course).permit(:name, :company, :tag_list)
  end
end
