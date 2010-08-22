<xsl:stylesheet 
version="1.0" 
xmlns="http://www.topografix.com/GPX/1/0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:fn="http://www.w3.org/2005/xpath-functions"
xmlns:vcc="http://www.velocitekspeed.com/VelocitekControlCenter"
  exclude-result-prefixes="vcc" 

d1p1:schemaLocation="http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd" 
xmlns:d1p1="http://www.w3.org/2001/XMLSchema-instance"

>
  <xsl:output method="xml" version="1.0" indent="yes"/>
  <xsl:template match="/">
    <gpx>
      
      <xsl:attribute name="d1p1:schemaLocation">http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd</xsl:attribute>      

      <xsl:attribute name="version">1.0</xsl:attribute>
      <xsl:attribute name="creator">Velocitek - http://www.velocitek.com</xsl:attribute>
          
      <xsl:apply-templates/>
    </gpx>
  </xsl:template>


  <xsl:template match="vcc:CapturedTrack">
    <name>
       <xsl:value-of select="@name"/>
    </name>

    <time>
       <xsl:value-of select="@downloadedOn"/>
	   <xsl:text>Z</xsl:text>	   
    </time>	
	

    <bounds 
        minlat="{vcc:MinLatitude}"
        minlon="{vcc:MinLongitude}"
        maxlat="{vcc:MaxLatitude}"
        maxlon="{vcc:MaxLongitude}"
     />
            
    

    <trk>
      <name>
        <xsl:value-of select="@name"/>
      </name>
      <xsl:apply-templates select="vcc:Trackpoints"/>
	        
    </trk>
  </xsl:template>
	
  <xsl:template match="vcc:Trackpoints">
    <trkseg>
      <xsl:apply-templates select="vcc:Trackpoint"/>
    </trkseg>
  </xsl:template>
  <xsl:template match="vcc:Trackpoint">
    <trkpt>
      <xsl:attribute name="lat">
        <xsl:value-of select="@latitude"/>
      </xsl:attribute>
      <xsl:attribute name="lon">
        <xsl:value-of select="@longitude"/>
      </xsl:attribute>
      <time>
        <xsl:value-of select="@dateTime"/>
        <xsl:text>Z</xsl:text>
      </time>
    </trkpt>
  </xsl:template>
</xsl:stylesheet>
