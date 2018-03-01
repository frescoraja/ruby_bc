class Block
  def initialize(block, nonce)
    @block, @nonce = block, nonce
    p "Created block with nonce: #{nonce}"
  end
end
