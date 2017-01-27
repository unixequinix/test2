# Wrappers for Material Design Lite text fields to use with SimpleForm (Rails)

SimpleForm.setup do |config|

  config.wrappers :mdl_field, tag: 'div', class: 'mdl-textfield mdl-js-textfield', error_class: 'is-invalid' do |b|
    b.use :html5
    b.use :placeholder
    b.use :hint
    b.use :input, class: 'mdl-textfield__input'
    b.use :label, class: 'mdl-textfield__label'
  end

  config.wrappers :mdl_field_floating, tag: 'div', class: 'mdl-textfield mdl-js-textfield mdl-textfield--floating-label', error_class: 'is-invalid' do |b|
    b.use :html5
    b.use :input, class: 'mdl-textfield__input'
    b.use :label, class: 'mdl-textfield__label'
    b.use :error, wrap_with: { tag: :span, class: 'mdl-textfield__error' }
  end

  config.wrappers :mdl_text_edit, tag: 'div', class: 'mdl-textfield mdl-js-textfield' do |b|
    b.use :html5
    b.use :input, class: 'mdl-textfield__input'
  end

  config.wrappers :mdl_switch, tag: 'div' do |b|
    b.use :html5
    b.use :input, class: 'mdl-switch__input', type: 'checkbox'
  end

  config.wrappers :mdl_upload, tag: 'div', class: 'mdl-textfield mdl-js-textfield mdl-textfield--file' do |b|
    b.use :html5
    b.use :input, class: 'mdl-textfield__input'
  end

  config.wrappers :mdl_boolean, tag: 'div', class: 'mdl-textfield mdl-js-textfield mdl-textfield--file' do |b|
    b.use :html5
    b.use :input, class: 'mdl-checkbox__input', type: 'checkbox'
  end

end

