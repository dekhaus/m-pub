class Product < ActiveRecord::Base
  after_create :publish_create
  after_update :publish_update
  after_destroy :publish_destroy
  
  private
    def publish_create
      message = {
        :product  => self.id,
        :klass    => 'product',
        :action   => :create,
        :name     => self.name }
      REDIS_PUB.publish("product.all", message)
    end
    
    def publish_update
      message = {
        :product  => self.id,
        :klass    => 'product',
        :action   => :update,
        :new_name => self.name,
        :old_name => self.name_was }
      REDIS_PUB.publish("product.all", message)
    end
    
    def publish_destroy
      message = {
        :product  => self.id,
        :klass    => 'product',
        :action   => :destroy,
        :name     => self.name }
      REDIS_PUB.publish("product.all", message)
    end
end
