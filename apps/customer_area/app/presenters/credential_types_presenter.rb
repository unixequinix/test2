class CredentialTypesPresenter
  attr_reader :assignment

  def initialize(assignment, context)
    @assignment = assignment
    @context = context
  end

  def credentiable
    @assignment.credentiable
  end

  def credentiable_name
    credentiable.company_ticket_type.name
  end

  def credentiable_type
    @context.content_tag("label", @assignment.credentiable_type)
  end

  def credentiable_code
    send("#{@assignment.credentiable_type.downcase}_renderer")
  end

  def products
    catalog_item = credentiable.company_ticket_type.credential_type.catalog_item

    if catalog_item.catalogable_type == "Pack"
      @products = catalog_item.catalogable
                  .pack_catalog_items
                  .includes(:catalog_item)
                  .map(&:catalog_item)
    else
      @products = [catalog_item]
    end
  end

  private

  def ticket_renderer
    @context.content_tag("li", credentiable.code)
  end

  def gtag_renderer
    @context.content_tag("li", "#{credentiable.tag_uid} #{credentiable.tag_serial_number}")
  end
end
