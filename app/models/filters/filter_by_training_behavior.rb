module Filters
  class FilterByTrainingBehavior < Filter
    def apply(extract_groups)
      case training_behavior
      when "ignore_training"
        extract_groups
      when "training_only"
        extract_groups.map do |extract_group|
          extract_group.select do |extract|
            extract.subject.training_subject?
          end
        end # select only training subjects
      when "experiment_only"
        extract_groups.map do |extract_group|
          extract_group.reject do |extract|
            extract.subject.training_subject?
          end
        end # reject all training subjects
      end
    end

    private

    def training_behavior
      @config["training_behavior"] || "ignore_training"
    end
  end
end