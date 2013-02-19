extractPreview <- function() {

    ## read the xad file and identify the tags
    originalLines <- readLines(file)
    tagLines <- which(grepl(pattern = "<", x = originalLines))

    previewData <- originalLines[tagLines[3]:(tagLines[4]-1)]

    startPos <- gregexpr(pattern = ":", previewData[1])[[1]][2]
    previewData[1] <- substr(previewData[1], startPos + 1, nchar(previewData[1]))
    previewData[length(previewData)] <- substr(previewData[length(previewData)], 1, nchar(previewData[length(previewData)])-3)

    tf1 <- tempfile()
    tf2 <- tempfile()
    writeLines(text = previewData, con = tf1)
    decode(tf1, tf2)

    f1 <- file(tf2, open = "r", encoding = "UTF-16LE")
    buffer <- readLines(con = f1)
    close(f1)
    writeLines(text = buffer, con = "/tmp/preview.xml")


}

extractCompressed <- function(file) {

    ## read the xad file and identify the tags
    originalLines <- readLines(file)
    tagLines <- which(grepl(pattern = "<", x = originalLines))

    
    compressedData <- originalLines[tagLines[5]:tagLines[6]]
    compressedData[1] <- substring(compressedData[1], first = nchar(compressedData[1]) - 71, nchar(compressedData[1]))

    compressedData[length(compressedData)] <- substr(compressedData[length(compressedData)], 1, nchar(compressedData[length(compressedData)]) - 18)

    compressedData[2] <- substring(compressedData[2], regexpr(compressedData[2], pattern = "Oy9")[1]-1, nchar(compressedData[2]))

    tf1 <- tempfile()
    tf2 <- tempfile()
    writeLines(text = compressedData[2:(length(compressedData))], con = tf1)
    decode(tf1, tf2)

    buffer <- readBin(con = tf2, n = 1e9, size = 1, signed = FALSE, what = integer())
    buffer <- buffer[ 2:(length(buffer) - 9) ]
    #writeBin(object = as.integer(buffer), con = tf2, size = 1)

    inflated <- .Call("inflateFile", buffer, PACKAGE="bioanalyzeR")
    ## add an new line to the end of the xml and write to disk
    inflated <- c(inflated, c(10L,0L))
    writeBin(object = inflated, con = tf1, size = 1)

    ## the UTF-16 encoding doesn't seem to agree with the XML package,
    ## so read it in, and right out as UTF-8.
    f1 <- file(tf1, open = "r", encoding = "UTF-16LE")
    buffer <- readLines(con = f1)
    close(f1)
    writeLines(text = buffer, con = "/tmp/inflated2.xml")

    ## read the final xml
    x1 <- xmlParse("/tmp/inflated2.xml")
}