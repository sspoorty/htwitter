class Tweet < ActiveRecord::Base
	include Twitter::Extractor

	def get_hashtags
		self.extract_hashtags(self.content)
	end

	belongs_to :user

	validates :content, length: { maximum: 140 }

	validate :hashtags_are_created

	def hashtags_are_created
		begin
			transaction do
				@hashtags = self.get_hashtags

				@hashtags.each do |the_hashtag|
					if Hashtag.where(tag: the_hashtag).any?
						# do nothing
					else
						if Hashtag.create!(tag:  the_hashtag)
							#do nothing
						else
							self.errors.add(:base, "Your hashtag #{the_hashtag} cannot be created")
						end
					end
				end
			end
		rescue
			#do stuff
			self.errors.add(:base, "Your tweet has a bad hashtag")
		end
	end

end
