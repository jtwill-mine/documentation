<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" version="2.0">

    <xsl:template match="*[contains(@class, ' map/topicmeta ')]">
        <fo:block-container xsl:use-attribute-sets="__frontmatter__owner__container">
            <fo:block>
                <xsl:apply-templates/>
            </fo:block>
        </fo:block-container>
    </xsl:template>

    <!--Set current page number - should this be in an xsl template instead of standalone?-->
    <fo:static-content flow-name="xsl-region-before">
        <fo:block text-align="end">Page<fo:page-number/></fo:block>
    </fo:static-content>
    
    <xsl:template match="*[contains(@class,' map/searchtitle ')]" priority="+2">
        <fo:block xsl:use-attribute-sets="__frontmatter__subtitle">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <!--Create Front Matter-->

    <xsl:template name="createFrontMatter_1.0">
        <fo:page-sequence master-reference="front-matter"
            xsl:use-attribute-sets="__force__page__count">
            <xsl:call-template name="insertFrontMatterStaticContents"/>
            <fo:flow flow-name="xsl-region-body">
                <fo:block xsl:use-attribute-sets="__frontmatter">
                    <!-- set the title -->
                    <fo:block xsl:use-attribute-sets="__frontmatter__title">
                        <xsl:choose>
                            <xsl:when test="$map/*[contains(@class,' topic/title ')][1]">
                                <xsl:apply-templates
                                    select="$map/*[contains(@class,' topic/title ')][1]"/>
                            </xsl:when>
                            <xsl:when test="$map//*[contains(@class,' bookmap/mainbooktitle ')][1]">
                                <xsl:apply-templates
                                    select="$map//*[contains(@class,' bookmap/mainbooktitle ')][1]"
                                />
                            </xsl:when>
                            <xsl:when test="//*[contains(@class, ' map/map ')]/@title">
                                <xsl:value-of select="//*[contains(@class, ' map/map ')]/@title"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="/descendant::*[contains(@class, ' topic/topic ')][1]/*[contains(@class, ' topic/title ')]"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>

                    <!-- set the subtitle -->
                    <xsl:apply-templates select="$map//*[contains(@class,' bookmap/booktitlealt ')]"/>

                    <fo:block xsl:use-attribute-sets="__frontmatter__owner">
                        <xsl:apply-templates select="$map//*[contains(@class,' bookmap/bookmeta ')]"
                        />
                    </fo:block>

                    <fo:block xsl:use-attribute-sets="__frontmatter__owner">
                        <xsl:apply-templates select="$map/*[contains(@class,' map/topicmeta')]"/>
                    </fo:block>

                    <!-- place company logo on PDF title page -->
                    <fo:block text-align="center" width="100%">
                        <fo:external-graphic
                            src="url({concat($artworkPrefix, '/Customization/OpenTopic/common/artwork/logo.png')})"
                        />
                    </fo:block>

                </fo:block>

                <!--<xsl:call-template name="createPreface"/>-->

            </fo:flow>
        </fo:page-sequence>
        <xsl:call-template name="createNotices"/>
    </xsl:template>
    
  <!-- <xsl:template name="insertBodyOddHeader"/>
        
    <xsl:template name="insertBodyEvenHeader"/>
            
    <xsl:template name="insertBodyOddFooter"/>
                
    <xsl:template name="insertBodyEvenFooter"/>
     
    <xsl:variable name="mirror-page-margins" select="true()"/> -->

 </xsl:stylesheet>
