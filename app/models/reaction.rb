class Reaction < ApplicationRecord
  default_scope { order("created_at DESC") }
  has_attached_file :video
  validates_attachment :video, content_type: { content_type: ["video/webm"] }
  validates_attachment_size :video, :in => 0.kilobytes..2300.kilobytes

  belongs_to :user
  belongs_to :post
end
