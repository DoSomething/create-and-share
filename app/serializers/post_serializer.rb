class PostSerializer < ActiveModel::Serializer
  attributes :id, :name, :city, :state, :promoted, :shares, :image, :story, :uid, :extras

  def shares
    {
      real: object.real_share_count,
      signed: object.share_count
    }
  end
  def image
    object.image.url(:gallery)
  end
end
