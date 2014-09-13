
module IncludeDateScopes
  module DefineCommonScopes
    def define_common_scopes(arel, prefix, column_name)
      t = arel

      define_singleton_method :"#{prefix}day" do |day|
        __send__(:"#{prefix}on", day)
      end

      define_singleton_method :"#{prefix}today" do
        __send__(:"#{prefix}on", Date.today)
      end

      define_singleton_method :"#{prefix}yesterday" do
        __send__(:"#{prefix}on", Date.yesterday)
      end

      define_singleton_method :"#{prefix}tomorrow" do
        __send__(:"#{prefix}on", Date.tomorrow)
      end

      [:day, :week, :month, :year].each do |time_unit|
        define_singleton_method :"#{prefix}next_#{time_unit}" do
          __send__(:"#{prefix}between", Time.now, 1.send(time_unit).from_now)
        end
        define_singleton_method :"#{prefix}last_#{time_unit}" do
          __send__(:"#{prefix}between", 1.send(time_unit).ago, Time.now)
        end
        define_singleton_method :"#{prefix}next_n_#{time_unit}s" do |count|
          __send__(:"#{prefix}between", Time.now, count.send(time_unit).from_now)
        end
        define_singleton_method :"#{prefix}last_n_#{time_unit}s" do |count|
          __send__(:"#{prefix}between", count.send(time_unit).ago, Time.now)
        end
      end

      define_singleton_method :"#{prefix}last_30_days" do
        __send__(:"#{prefix}last_n_days", 30)
      end

      define_singleton_method :"#{prefix}most_recent" do
        order("#{column_name} desc")
      end
    end
  end
end
