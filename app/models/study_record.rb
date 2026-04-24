class StudyRecord < ApplicationRecord

  belongs_to :user, dependent: :destroy

end
