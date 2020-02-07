<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:yed="http://bp4mc2.org/yed#"
	xmlns:elmo="http://bp4mc2.org/elmo/def#"
	xmlns:y="http://www.yworks.com/xml/graphml"
>

<xsl:key name="nodes" match="/rdf:RDF/rdf:Description[exists(rdf:type)]" use="@rdf:about"/>
<xsl:key name="items" match="/rdf:RDF/rdf:Description" use="@rdf:about"/>
<xsl:key name="blanks" match="/rdf:RDF/rdf:Description" use="@rdf:nodeID"/>
<!-- Fragments don't work in this version -->
<xsl:key name="fragments" match="/root/view/representation[1]/fragment" use="@applies-to"/>

<xsl:template match="/">
	<graphml>
		<key attr.name="url" attr.type="string" for="node" id="d3"/>
		<key attr.name="url" attr.type="string" for="edge" id="d7"/>
		<key attr.name="subject-uri" attr.type="string" for="edge" id="d90"/>
		<key attr.name="object-uri" attr.type="string" for="edge" id="d91"/>
		<key for="node" id="d6" yfiles.type="nodegraphics"/>
		<key for="edge" id="d10" yfiles.type="edgegraphics"/>
		<graph id="G" edgedefault="directed">
			<xsl:apply-templates select="rdf:RDF"/>
		</graph>
	</graphml>
</xsl:template>

<xsl:template match="*" mode="yed-default-node">
	<xsl:param name="geometry"/>
	<xsl:param name="uripostfix"/>

	<xsl:variable name="slabel"><xsl:value-of select="replace(@rdf:about,'^.*(#|/)([^(#|/)]+)$','$2')"/></xsl:variable>
	<xsl:variable name="label">
		<xsl:value-of select="rdfs:label"/>
		<xsl:if test="not(rdfs:label!='')">
			<xsl:value-of select="$slabel"/>
			<xsl:if test="$slabel=''"><xsl:value-of select="@rdf:about"/></xsl:if>
		</xsl:if>
	</xsl:variable>
	<xsl:variable name="fragment" select="key('fragments',elmo:style[1])"/>
	<xsl:variable name="backgroundColor">
		<xsl:value-of select="$fragment/yed:backgroundColor"/>
		<xsl:if test="not(exists($fragment/yed:backgroundColor))">#FFFFFF</xsl:if> <!-- #B7C9E3 -->
	</xsl:variable>
	<xsl:variable name="modelposition">
		<xsl:choose>
			<xsl:when test="exists(rdfs:comment)">t</xsl:when>
			<xsl:otherwise>c</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<node id="{@rdf:about}{@rdf:nodeID}{$uripostfix}"> <!-- URI nodes and blank nodes -->
		<data key="d3"><xsl:value-of select="@rdf:about"/><xsl:value-of select="@rdf:nodeID"/></data>
		<data key="d6">
			<xsl:variable name="nodeConfiguration">
				<xsl:value-of select="$fragment/yed:nodeType"/>
				<xsl:if test="not(exists($fragment/yed:nodeType))">com.yworks.entityRelationship.big_entity</xsl:if>
			</xsl:variable>
			<xsl:variable name="nodeType">
					<xsl:choose>
						<xsl:when test="$nodeConfiguration='ellipse'">y:ShapeNode</xsl:when>
						<xsl:when test="$nodeConfiguration='roundrectangle'">y:ShapeNode</xsl:when>
						<xsl:otherwise>y:GenericNode</xsl:otherwise>
					</xsl:choose>
			</xsl:variable>
			<xsl:element name="{$nodeType}">
				<xsl:choose>
					<xsl:when test="$nodeType='y:GenericNode'">
						<xsl:attribute name="configuration"><xsl:value-of select="$nodeConfiguration"/></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<y:Shape type="{$nodeConfiguration}"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="exists($geometry)">
						<y:Geometry height="{$geometry/yed:height}" width="{$geometry/yed:width}" x="{$geometry/yed:x}" y="{$geometry/yed:y}"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
								<xsl:when test="$nodeType='y:GenericNode'"><y:Geometry height="100.0" width="200.0" x="0.5" y="0"/></xsl:when>
								<xsl:otherwise><y:Geometry height="30.0" width="200.0" x="0.5" y="0"/></xsl:otherwise>
							</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="not(exists($fragment/yed:fill))"><y:Fill color="#E8EEF7" color2="#B7C9E3" transparent="false"/></xsl:when>
					<xsl:otherwise>
						<y:Fill color="{$fragment/yed:fill}" transparant="false">
							<xsl:if test="exists($fragment/yed:fill2)"><xsl:attribute name="color2"><xsl:value-of select="$fragment/yed:fill2"/></xsl:attribute></xsl:if>
						</y:Fill>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:variable name="borderstyle">
					<xsl:choose>
							<xsl:when test="exists($fragment/yed:color)">
								<color><xsl:value-of select="$fragment/yed:color"/></color>
								<width>1.0</width>
							</xsl:when>
							<xsl:otherwise>
								<color>#000000</color>
								<width>1.0</width>
							</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<y:BorderStyle color="{$borderstyle/color}" type="line" width="{$borderstyle/width}"/>
				<y:NodeLabel alignment="center" autoSizePolicy="node_width" configuration="CroppingLabel" fontFamily="Dialog" fontSize="12" fontStyle="plain" hasLineColor="false" modelName="internal" modelPosition="{$modelposition}" textColor="#000000" visible="true">
					<xsl:choose>
						<xsl:when test="$fragment/yed:backgroundColor!=''"><xsl:attribute name="backgroundColor"><xsl:value-of select="$fragment/yed:backgroundColor"/></xsl:attribute></xsl:when>
						<xsl:otherwise><xsl:attribute name="hasBackgroundColor">false</xsl:attribute></xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="$label"/>
				</y:NodeLabel>
				<y:NodeLabel alignment="left" autoSizePolicy="node_width" configuration="CroppingLabel" fontFamily="Dialog" fontSize="10" fontStyle="plain" hasBackgroundColor="false" hasLineColor="false" modelName="custom" textColor="#000000" visible="true">
					<xsl:for-each select="rdfs:comment">
						<xsl:if test="position()!=1"><xsl:text>
</xsl:text></xsl:if><xsl:value-of select="."/>
					</xsl:for-each>
					<y:LabelModel>
						<y:ErdAttributesNodeLabelModel/>
					</y:LabelModel>
					<y:ModelParameter>
						<y:ErdAttributesNodeLabelModelParameter/>
					</y:ModelParameter>
				</y:NodeLabel>
				<y:StyleProperties>
					<y:Property class="java.lang.Boolean" name="y.view.ShadowNodePainter.SHADOW_PAINTING" value="true"/>
				</y:StyleProperties>
			</xsl:element>
		</data>
	</node>
</xsl:template>

<xsl:template match="rdf:RDF">
	<!-- Nodes -->
	<xsl:for-each select="rdf:Description[exists(rdf:type)]">
		<xsl:variable name="resource" select="."/>
		<xsl:apply-templates select="$resource" mode="yed-default-node">
			<xsl:with-param name="geometry" select="key('blanks',yed:geometry[1]/@rdf:nodeID)"/>
		</xsl:apply-templates>
		<xsl:for-each select="yed:geometry[position()!=1]">
			<xsl:apply-templates select="$resource" mode="yed-default-node">
				<xsl:with-param name="uripostfix">___<xsl:value-of select="position()"/></xsl:with-param>
				<xsl:with-param name="geometry" select="key('blanks',@rdf:nodeID)"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:for-each>
	<!-- Edges for URI nodes -->
	<xsl:for-each select="rdf:Description/*[exists(key('nodes',@rdf:resource))]">
		<xsl:variable name="puri"><xsl:value-of select="namespace-uri()"/><xsl:value-of select="local-name()"/></xsl:variable>
		<xsl:variable name="pfragment" select="key('fragments',$puri)"/>
		<xsl:variable name="label">
			<xsl:value-of select="$pfragment/rdfs:label"/>
			<xsl:if test="not(exists($pfragment/rdfs:label))">
				<xsl:variable name="plabel"><xsl:value-of select="key('items',$puri)/rdfs:label"/></xsl:variable>
				<xsl:value-of select="$plabel"/>
				<xsl:if test="$plabel=''"><xsl:value-of select="name()"/></xsl:if>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="source">
			<xsl:value-of select="$pfragment/yed:sourceArrow"/>
			<xsl:if test="not(exists($pfragment/yed:sourceArrow))">none</xsl:if>
		</xsl:variable>
		<xsl:variable name="target">
			<xsl:value-of select="$pfragment/yed:targetArrow"/>
			<xsl:if test="not(exists($pfragment/yed:targetArrow))">standard</xsl:if>
		</xsl:variable>
		<xsl:variable name="line">
			<xsl:value-of select="$pfragment/yed:line"/>
			<xsl:if test="not(exists($pfragment/yed:line))">line</xsl:if>
		</xsl:variable>
		<xsl:variable name="edgetype">
			<xsl:choose>
				<xsl:when test="$pfragment/yed:edge/@rdf:resource='http://bp4mc2.org/yed#BezierEdge'">y:BezierEdge</xsl:when>
				<xsl:when test="$pfragment/yed:edge/@rdf:resource='http://bp4mc2.org/yed#PolyLineEdge'">y:PolyLineEdge</xsl:when>
				<xsl:otherwise>y:PolyLineEdge</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<edge source="{../@rdf:about}" target="{@rdf:resource}">-
			<data key="d10">
				<xsl:element name="{$edgetype}">
					<y:LineStyle color="#000000" type="{$line}" width="1.0"/>
					<y:Arrows source="{$source}" target="{$target}"/>
					<y:EdgeLabel alignment="center" backgroundColor="#FFFFFF" configuration="AutoFlippingLabel" distance="2.0" fontFamily="Dialog" fontSize="12" fontStyle="plain" hasLineColor="false" modelName="custom" preferredPlacement="anywhere" ratio="0.5" textColor="#000000" visible="true"><xsl:value-of select="$label"/><y:LabelModel>
							<y:SmartEdgeLabelModel autoRotationEnabled="false" defaultAngle="0.0" defaultDistance="10.0"/>
						</y:LabelModel>
						<y:ModelParameter>
							<y:SmartEdgeLabelModelParameter angle="0.0" distance="30.0" distanceToCenter="true" position="center" ratio="0.5" segment="0"/>
						</y:ModelParameter>
						<y:PreferredPlacementDescriptor angle="0.0" angleOffsetOnRightSide="0" angleReference="absolute" angleRotationOnRightSide="co" distance="-1.0" frozen="true" placement="anywhere" side="anywhere" sideReference="relative_to_edge_flow"/>
					</y:EdgeLabel>
					<y:BendStyle smoothed="false"/>
				</xsl:element>
			</data>
		</edge>
	</xsl:for-each>
	<!-- Edges for blank nodes -->
	<xsl:for-each select="rdf:Description/*[exists(key('blanks',@rdf:nodeID)/rdf:type)]">
		<edge source="{../@rdf:about}" target="{@rdf:nodeID}">-
			<data key="d10">
				<y:PolyLineEdge>
					<y:LineStyle color="#000000" type="line" width="1.0"/>
					<y:Arrows source="none" target="standard"/>
					<y:EdgeLabel alignment="center" backgroundColor="#FFFFFF" configuration="AutoFlippingLabel" distance="2.0" fontFamily="Dialog" fontSize="12" fontStyle="plain" hasLineColor="false" modelName="custom" preferredPlacement="anywhere" ratio="0.5" textColor="#000000" visible="true"><xsl:value-of select="name()"/><y:LabelModel>
							<y:SmartEdgeLabelModel autoRotationEnabled="false" defaultAngle="0.0" defaultDistance="10.0"/>
						</y:LabelModel>
						<y:ModelParameter>
							<y:SmartEdgeLabelModelParameter angle="0.0" distance="30.0" distanceToCenter="true" position="center" ratio="0.5" segment="0"/>
						</y:ModelParameter>
						<y:PreferredPlacementDescriptor angle="0.0" angleOffsetOnRightSide="0" angleReference="absolute" angleRotationOnRightSide="co" distance="-1.0" frozen="true" placement="anywhere" side="anywhere" sideReference="relative_to_edge_flow"/>
					</y:EdgeLabel>
					<y:BendStyle smoothed="false"/>
				</y:PolyLineEdge>
			</data>
		</edge>
	</xsl:for-each>
</xsl:template>

</xsl:stylesheet>
