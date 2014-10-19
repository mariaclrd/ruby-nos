module RubyNos
  class AgentsCollection
    include Initializable
    attr_accessor :db, :conditions

    def conditions
      @conditions ||= {}
    end

    protected(:conditions, :conditions=)

    def for_agent_uuid uuid
      dup.tap do |d|
        d.conditions = conditions.merge({:agent_uuid => uuid})
      end
    end

    def create args
      agent      = build_new(args)
      save_to_db agent
      agent
    end

    def update agent
      db.where(:agent_uuid => agent.uuid).update(agent.to_hash)
      agent
    end

    def delete
      query.delete
    end

    def to_a
      query.map{|entry| build_from_entry entry}
    end

    def map &block
      agents_array.map &block
    end

    def agents_array
      @agents_array ||= to_a
    end

    private

    def query
      db.where(conditions)
    end

    def save_to_db agent
      db.insert(agent.to_hash)
    end

    def build_from_entry entry
      agent               = Agent.new
      agent.uuid          = entry[:agent_uuid]
      agent
    end

    def build_new args ={}
      agent               = Agent.new
      agent.uuid          = args[:agent_uuid]
      agent
    end
  end
end