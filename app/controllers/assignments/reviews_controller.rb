class Assignments::ReviewsController < ApplicationController
  before_filter :find_assignment_submission
  before_filter :find_review, :only => [:show, :edit, :update, :comment]
  before_filter :student_or_instructor_only, :except => [:index]
  
  def index
    @reviews = Assignment::Review.where(:submission_id => @submission.id)
  end
  
  def new
    if @submission.open_review?
      redirect_to assignment_review_path(@assignment.id, @submission.review.id)
    else
      @review = @submission.reviews.build
    end
  end
  
  def create
    @review = @submission.reviews.new(params[:assignment_review])
    
    if @review.save
      UserMailer.review_created(@review).deliver
      
      flash[:notice] = "Review submitted"
      redirect_to root_path
    else
      render :action => :new
    end
  end
  
  def show
    render :action => :edit
  end
  
  def edit
    
  end
  
  def update
    @review.update_attribute(:closed, true)
    
    @review.submission.update_attributes(params[:assignment_review]['assignment_submission'])
    
    flash[:notice] = "Review closed"
    
    UserMailer.review_closed(@review, current_user).deliver
    
    redirect_to root_path
  end
  
  def comment
    comment = @review.comments.create(params[:comment].
                merge(:user_id => current_user.id))
    
    UserMailer.review_comment_created(comment, @review, current_user).deliver
    
    redirect_to assignment_review_path(@assignment, @review)
  end
  
  private
  
  def find_assignment_submission
    @assignment = Assignment.find(params[:assignment_id])
    @submission = @assignment.submission_for(current_user)
  end
  
  def find_review
    @review = Assignment::Review.find(params[:id])
  end
  
  def student_or_instructor_only
    find_review if params[:id]
    
    if (@review && @review.submission.user != current_user) and
       !@assignment.course.instructors.include?(current_user)
      
      raise "Access Denied"
      
    end
  end
end
