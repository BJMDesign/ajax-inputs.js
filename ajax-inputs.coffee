$ = jQuery
defaults = 
	selector: 'input'
	events: 'change'
	method: 'POST'
	# parameters to be sent with all requests
	data: {}
	dataType: 'json'

namespace = 'ajaxInputs'
$.fn[namespace] =
	defaults: defaults 

##
# options.url (required) Defines the URL that should be called on change.
#   The input name and value attributes will be appended to this URL as name=value
$.fn[namespace] = (option)->
	args = arguments
	return this.each ->
		$this = $(this)
		options = option if typeof option == 'object'
		data = $this.data(namespace)
		if !data then $this.data(namespace, data = new AjaxInputs(this, options))
		if typeof option == 'string'
			args = Array.prototype.slice.call(arguments, 0)
			args.shift()
			data[option].apply data, args

class AjaxInputs
	constructor: (el, @options)->
		@$el = $(el)
		@options = $.extend {}, defaults, @options
		@$el.on @options.events, @options.selector, $.proxy @onChange, @
	onChange: (e)->
		$input = $(e.target)
		data = $.extend {}, @options.data
		data[$input.attr 'name'] = $input.val()
		(($input)=>
			$.ajax
				url: @options.url
				data: data
				type: @options.method
				dataType: @options.dataType
				success: (response)=>
					if $.fn.formUnload then @$el.closest('form').formUnload('stored', $input)
					@$el.trigger "#{namespace}:done", response, e
			.fail (jqXHR)=>
				@$el.trigger "#{namespace}:fail", jqXHR, e
			.always (response)=>
				@$el.trigger "#{namespace}:always", response, e
		)($input)