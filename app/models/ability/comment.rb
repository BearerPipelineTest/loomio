module Ability::Comment
  def initialize(user)
    super(user)

    can [:create], ::Comment do |comment|
      comment.discussion && comment.discussion.members.exists?(user.id)
    end

    can [:update], ::Comment do |comment|
      !comment.discarded_at &&
      ((comment.discussion.members.exists?(user.id) && comment.author == user && comment.can_be_edited?) ||
      (comment.discussion.admins.exists?(user.id) && comment.group.admins_can_edit_user_content))
    end
    
    can [:discard, :undiscard], ::Comment do |comment|
      (comment.author == user && can?(:update, comment)) ||
      comment.discussion.admins.exists?(user.id)
    end

    can [:destroy], ::Comment do |comment|
      (comment.author == user && comment.discussion.members.exists?(user.id) && comment.group.members_can_delete_comments) ||
      comment.discussion.admins.exists?(user.id)
    end

    can [:show], ::Comment do |comment|
      can?(:show, comment.discussion) && comment.kept?
    end
  end
end
