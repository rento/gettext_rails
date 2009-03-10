=begin
  gettext_rails/action_view/active_record_helper.rb- GetText for ActionView.

  Copyright (C) 2005-2009  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  Original: gettext/lib/rails.rb from Ruby-GetText-Package-1.93.0

  $Id$
=end

module ActionView #:nodoc:
  module Helpers  #:nodoc:
    module ActiveRecordHelper #:nodoc: all
      module L10n
        # Separate namespace for textdomain
        include GetText

        bindtextdomain "gettext_rails"

        @@error_message_headers ={
          :header => Nn_("%{num} error prohibited this %{record} from being saved", 
                         "%{num} errors prohibited this %{record} from being saved"),
          :body => Nn_("There was a problem with the following field:", 
                     "There were problems with the following fields:")
        }
        
        module_function
        # call-seq:
        # set_error_message_title(msgs)
        #
        # Sets a your own title of error message dialog.
        # * msgs: [single_msg, plural_msg]. Usually you need to call this with Nn_().
        # * Returns: [single_msg, plural_msg]
        def set_error_message_title(msg, plural_msg = nil)
          if msg.kind_of? Array
            single_msg = msg[0]
            plural_msg = msg[1]
          else
            single_msg = msg
          end
          @@error_message_headers[:header] = [single_msg, plural_msg]
        end
        
        # call-seq:
        # set_error_message_explanation(msg)
        #
        # Sets a your own explanation of the error message dialog.
        # * msg: [single_msg, plural_msg]. Usually you need to call this with Nn_().
        # * Returns: [single_msg, plural_msg]
        def set_error_message_explanation(msg, plural_msg = nil)
          if msg.kind_of? Array
            single_msg = msg[0]
            plural_msg = msg[1]
          else
            single_msg = msg
          end
          @@error_message_headers[:body] = [single_msg, plural_msg]
        end

        def error_message(key, model, count) #:nodoc:
          return nil if key.nil?
           
          if key.kind_of? Symbol
            msgids = @@error_message_headers[key]
          else
            msgids = key
          end

          model = _(model)
          if msgids
            ngettext(msgids, count) % {:num => count, :count => count, 
              :record => model, :model => model} # :num, :record are for backward compatibility.
          else
            nil
          end
        end

      end

      def error_messages_for_with_gettext_rails(*params) #:nodoc:
        model = params[0]
        options = params.extract_options!.symbolize_keys

        header_message = options[:header_message] || options[:message_title] || :header
        message = options[:message] || options[:message_explanation] || :body

        object = options.delete(:object)
        if object
          objects = [object].flatten
        else
          objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
        end
        count  = objects.inject(0) {|sum, object| sum + object.errors.count }

        options[:object_name] ||= params.first
        normalized_model = options[:object_name].to_s.gsub('_', ' ')
        
        options[:header_message] = L10n.error_message(header_message, normalized_model, count)
        options[:message] = L10n.error_message(message, normalized_model, count)

        error_messages_for_without_gettext_rails(model, options)
      end
      alias_method_chain :error_messages_for, :gettext_rails

    end
  end
end
