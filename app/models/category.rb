class Category < ActiveRecord::Base
  after_create  :publish_create
  after_update  :publish_update
  after_destroy :publish_destroy
  
  private
    def publish_create
      message = {
        :category => self.id,
        :klass    => 'category',
        :action   => :create,
        :name     => self.name }
      REDIS_PUB.publish("category.all", message)
    end
    
    def publish_update
      message = {
        :category => self.id,
        :klass    => 'category',
        :action   => :update,
        :new_name => self.name,
        :old_name => self.name_was }
      REDIS_PUB.publish("category.all", message)
    end
    
    def publish_destroy
      message = {
        :category => self.id,
        :klass    => 'category',
        :action   => :destroy,
        :name     => self.name }
      REDIS_PUB.publish("category.all", message)
    end
end
