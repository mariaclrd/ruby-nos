module Initializable

  def initialize args = {}
    set_attributes(args)
  end

  private

  def set_attributes args
    args.each do |k,v|
      send("#{k}=",v)
    end
  end
end