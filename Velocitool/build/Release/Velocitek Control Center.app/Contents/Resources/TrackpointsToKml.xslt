<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  version="1.0" 
  xmlns="http://earth.google.com/kml/2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:vcc="http://www.velocitekspeed.com/VelocitekControlCenter"
  exclude-result-prefixes="vcc" 
  >
  <xsl:output method="xml" version="1.0" indent="yes"/>
  <xsl:template match="/">
    <kml>
      <xsl:apply-templates/>
    </kml>
  </xsl:template>
  <xsl:template match="vcc:CapturedTrack">
    <Placemark>
      <description>Velocitek KML output</description>
      <name>
        <xsl:value-of select="@name"/>
      </name>
      <LookAt>
        <longitude>
          <xsl:value-of select="(vcc:MinLongitude + vcc:MaxLongitude) div 2"/>
        </longitude>
        <latitude>
          <xsl:value-of select="(vcc:MinLatitude + vcc:MaxLatitude) div 2"/>
        </latitude>
        <range>4000.0</range>
        <tilt>0.0</tilt>
        <heading>0.0</heading>
      </LookAt>
      <visibility>1</visibility>
      <open>0</open>
      <Style>
        <LineStyle>
          <color>ffffffff</color>
          <width>4</width>
        </LineStyle>
      </Style>
      <xsl:apply-templates select="vcc:Trackpoints"/>
    </Placemark>
  </xsl:template>
  <xsl:template match="vcc:Trackpoints">
    <LineString xmlns="http://earth.google.com/kml/2.0">
      <coordinates>
        <xsl:apply-templates select="vcc:Trackpoint"/>
      </coordinates>
    </LineString>
  </xsl:template>
  <xsl:template match="vcc:Trackpoint">
    <xsl:value-of select="@longitude"/>,<xsl:value-of select="@latitude"/>,0<xsl:text> 
</xsl:text>
  </xsl:template>
</xsl:stylesheet>
