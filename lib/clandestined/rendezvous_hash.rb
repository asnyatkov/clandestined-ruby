require 'murmur3'

module Clandestined
  class RendezvousHash

    include Murmur3

    attr_reader :nodes
    attr_reader :seed
    attr_reader :hash_function

    def initialize(nodes=nil, seed=0)
      if nodes
        @nodes = nodes.map!{|node_id| node_id.to_s}
      else
        @nodes = []
      end
      @seed = seed

      @hash_function = lambda { |key| murmur3_32(key, seed) }
    end

    def add_node(node)
      @nodes.push(node.to_s) unless @nodes.include?(node)
    end

    def remove_node(node)
      if @nodes.include?(node.to_s)
        @nodes.delete(node.to_s)
      else
        raise ArgumentError, "No such node #{node} to remove"
      end
    end

    def find_node(key)
      scores = Hash[]
      nodes.each do |node|
        score = hash_function.call("#{node}-#{key}")
        scores[score] = scores.fetch(score, []) << node
      end
      scores.max[1].max
    end

  end
end
