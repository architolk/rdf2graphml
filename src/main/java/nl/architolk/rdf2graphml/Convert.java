package nl.architolk.rdf2graphml;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.apache.jena.rdf.model.Model;
import org.apache.jena.riot.RDFDataMgr;
import org.apache.jena.riot.RDFFormat;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Convert {

  private static final Logger LOG = LoggerFactory.getLogger(Convert.class);

  public static void main(String[] args) {

    if (args.length == 3) {

      String transformer = "xsl/rdf2rdf.xsl";
      if (args[0].equals("-d")) {
        transformer = "xsl/rdf2datagraph.xsl";
        LOG.info("Starting data visualisation");
      } else if (args[0].equals("-m")) {
        transformer = "xsl/rdf2modelgraph.xsl";
        LOG.info("Starting model visualisation");
      } else {
        LOG.warn("Unknown option: {}",args[0]);
      }
      LOG.info("Input file: {}",args[1]);
      LOG.info("Ouput file: {}",args[2]);

      try {
        Model model = RDFDataMgr.loadModel(args[1]);
        // A better solution would be to use pipes in seperate threads
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        RDFDataMgr.write(buffer, model, RDFFormat.RDFXML_PLAIN);
        XmlEngine.transform(new StreamSource(new ByteArrayInputStream(buffer.toByteArray())),transformer,new StreamResult(new File(args[2])));
        LOG.info("Done!");
      }
      catch (Exception e) {
        LOG.error(e.getMessage(),e);
      }
    } else {
      LOG.warn("Usage: rdf2graphml [-d|-m] <input> <output.graphml>");
    }
  }
}
