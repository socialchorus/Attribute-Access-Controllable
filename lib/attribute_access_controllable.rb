module AttributeAccessControllable
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Validations
    serialize :read_only_attributes
    attr_accessor :skip_read_only # TODO: Really should name this something private (e.g. :_#{class_name}_skip_read_only)
    validate :read_only_attributes_unchanged, :on => :update, :unless => :skip_read_only
  end

  # Mark an attribute as read-only
  # @param [Symbol] attributes on the model
  # @return [void]
  def attr_read_only(*attributes)
    self.read_only_attributes = Set.new(attributes.map { |a| a.to_s }) + (read_only_attributes || [])
  end

  # @param [Symbol] attribute on the model
  # @return [Boolean] attribute is read-only
  def read_only_attribute?(attribute)
    return false if read_only_attributes.nil?
    read_only_attributes.member?(attribute.to_s)
  end

  def save(options = {})
    self.skip_read_only = options.delete(:skip_read_only)
    super
  end

  def save!(options = {})
    self.skip_read_only = options.delete(:skip_read_only)
    super
  end

  private
  
  def read_only_attributes_unchanged
    changed_attributes.each_key do |attr|
      errors.add(attr) << "is read_only" if read_only_attribute?(attr)
    end
  end
end
