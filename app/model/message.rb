class Message < ActiveRecord::Base
  has_and_belongs_to_many :articles
  belongs_to :user
end