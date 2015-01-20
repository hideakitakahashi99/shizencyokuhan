class StaffMember < ActiveRecord::Base
	include EmailHolder
	include PersonalNameHolder


	has_many :events, class_name: 'StaffEvent', dependent: :destroy
	has_many :microposts, dependent: :destroy
	has_one :staff_address, dependent: :destroy
	has_many :schedules, dependent: :destroy
	has_many :products, dependent: :destroy
	has_many :reverse_relationships, foreign_key: "followed_id",
		class_name: "Relationship",
		dependent: :destroy
	has_many :followers, through: :reverse_relationships, source: :follower

	
	mount_uploader :image, ImageUploader

	validates :start_date,presence: true, date: {
		after_or_equal_to: Date.new(2000, 1, 1),
		before: -> (obj) { 1.year.from_now.to_date },
		allow_blank: true
	}
	validates :end_date, date: {
		after: :start_date,
		before: -> (obj) { 1.year.from_now.to_date },
		allow_blank: true
	}


	def password=(raw_password)
		if raw_password.kind_of?(String)
			self.hashed_password = BCrypt::Password.create(raw_password)
		elsif raw_password.nil?
			self.hashed_password = nil
		end
	end

	def active?
		!suspended? && start_date <= Date.today &&
		(end_date.nil? || end_date > Date.today)
	end
end
