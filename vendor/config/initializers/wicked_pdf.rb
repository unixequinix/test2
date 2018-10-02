# WickedPDF Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# models by passing arguments to the `render :pdf` call.
#
# To learn more, check out the README:
#
# https://github.com/mileszs/wicked_pdf/blob/master/README.md

WickedPdf.config = {
  # Path to the wkhtmltopdf executable: This usually isn't needed if using
  # one of the wkhtmltopdf-binary family of gems.
  # exe_path: '/usr/local/bin/wkhtmltopdf',
  #   or
  # exe_path: Gem.bin_path('wkhtmltopdf-binary', 'wkhtmltopdf')

  # Layout file to be used for all PDFs
  # (but can be overridden in `render :pdf` calls)
  layout: 'pdf',
  header: { 
    html: {
      template: 'layouts/pdfs/header.html'
    },
    spacing: 10
  },
  footer: { 
    font_name: "Helvetica",
    font_size: 10,
    right: 'Page [page] of [topage]',
    html: {
      template: 'layouts/pdfs/footer.html'
    } 
  },
  disable_internal_links: true,
  disable_external_links: true,
  disable_smart_shrinking: false
}
