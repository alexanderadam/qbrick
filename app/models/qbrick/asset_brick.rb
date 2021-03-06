module Qbrick
  class AssetBrick < Brick
    mount_uploader :asset, Qbrick::AssetBrickAssetUploader

    validates :caption,
              :asset, presence: true

    def self.styles
      %w(pdf word excel button)
    end

    def to_style_class
      [super, link_style.presence].join(' ')
    end

    def collect_fulltext
      [super, caption].join(' ')
    end

    def user_can_add_childs?
      false
    end

    delegate :present?, to: :asset, prefix: true
  end
end
