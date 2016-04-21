class Reaction < ApplicationRecord
  has_attached_file :video
  validates_attachment :video, content_type: { content_type: ["video/webm"] }
  validates_attachment_size :video, :in => 0.megabytes..1.megabytes

  belongs_to :user
  belongs_to :post
end
