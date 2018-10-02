class ExcelIO
  def initialize(stream)
    @stream = stream
  end

  def <<(data)
    @stream.write(data)
  end

  def close
    @stream.close
  end
end
