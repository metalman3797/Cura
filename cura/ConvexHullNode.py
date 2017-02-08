# Copyright (c) 2015 Ultimaker B.V.
# Cura is released under the terms of the AGPLv3 or higher.

from UM.Application import Application
from UM.Scene.SceneNode import SceneNode
from UM.Resources import Resources
from UM.Math.Color import Color
from UM.Mesh.MeshBuilder import MeshBuilder  # To create a mesh to display the convex hull with.

from UM.View.GL.OpenGL import OpenGL

class ConvexHullNode(SceneNode):
    ##  Convex hull node is a special type of scene node that is used to display an area, to indicate the
    #   location an object uses on the buildplate. This area (or area's in case of one at a time printing) is
    #   then displayed as a transparent shadow. If the adhesion type is set to raft, the area is extruded
    #   to represent the raft as well.
    def __init__(self, node, hull, thickness, parent = None):
        super().__init__(parent)

        self.setCalculateBoundingBox(False)

        self._shader = None

        self._original_parent = parent

        # Color of the drawn convex hull
        self._color = None

        # The y-coordinate of the convex hull mesh. Must not be 0, to prevent z-fighting.
        self._mesh_height = 0.1

        self._thickness = thickness

        # The node this mesh is "watching"
        self._node = node
        self._convex_hull_head_mesh = None

        self._node.decoratorsChanged.connect(self._onNodeDecoratorsChanged)
        self._onNodeDecoratorsChanged(self._node)

        self._hull = hull
        if self._hull:
            hull_mesh_builder = MeshBuilder()

            if hull_mesh_builder.addConvexPolygonExtrusion(
                self._hull.getPoints()[::-1],  # bottom layer is reversed
                self._mesh_height-thickness, self._mesh_height, color=self._color):

                hull_mesh = hull_mesh_builder.build()
                self.setMeshData(hull_mesh)

    def getHull(self):
        return self._hull

    def getThickness(self):
        return self._thickness

    def getWatchedNode(self):
        return self._node

    def render(self, renderer):
        if not self._shader:
            self._shader = OpenGL.getInstance().createShaderProgram(Resources.getPath(Resources.Shaders, "transparent_object.shader"))
            self._shader.setUniformValue("u_diffuse_color", self._color)
            self._shader.setUniformValue("u_opacity", 0.6)

        if self.getParent():
            if self.getMeshData():
                renderer.queueNode(self, transparent = True, shader = self._shader, backface_cull = True, sort = -8)
                if self._convex_hull_head_mesh:
                    renderer.queueNode(self, shader = self._shader, transparent = True, mesh = self._convex_hull_head_mesh, backface_cull = True, sort = -8)

        return True

    def _onNodeDecoratorsChanged(self, node):
        self._color = Color(*Application.getInstance().getTheme().getColor("convex_hull").getRgb())

        convex_hull_head = self._node.callDecoration("getConvexHullHead")
        if convex_hull_head:
            convex_hull_head_builder = MeshBuilder()
            convex_hull_head_builder.addConvexPolygon(convex_hull_head.getPoints(), self._mesh_height - self._thickness)
            self._convex_hull_head_mesh = convex_hull_head_builder.build()

        if not node:
            return

