[shaders]
vertex =
    uniform highp mat4 u_modelMatrix;
    uniform highp mat4 u_viewProjectionMatrix;
    uniform highp mat4 u_normalMatrix;

    attribute highp vec4 a_vertex;
    attribute highp vec4 a_normal;
    attribute highp vec2 a_uvs;

    varying highp vec3 v_position;
    varying highp vec3 v_vertex;
    varying highp vec3 v_normal;

    void main()
    {
        vec4 world_space_vert = u_modelMatrix * a_vertex;
        gl_Position = u_viewProjectionMatrix * world_space_vert;

        v_position = gl_Position.xyz;
        v_vertex = world_space_vert.xyz;
        v_normal = (u_normalMatrix * normalize(a_normal)).xyz;
    }

fragment =
    uniform mediump vec4 u_ambient_color;
    uniform mediump vec4 u_diffuse_color1;
    uniform mediump vec4 u_diffuse_color2;
    uniform mediump vec4 u_specular_color;
    uniform highp vec3 u_lightPosition;
    uniform mediump float u_shininess;
    uniform highp vec3 u_viewPosition;

    uniform mediump float u_width;

    varying highp vec3 v_position;
    varying highp vec3 v_vertex;
    varying highp vec3 v_normal;

    void main()
    {
        mediump vec4 finalColor = vec4(0.0);
        mediump vec4 diffuseColor = (mod((-v_position.x + v_position.y), u_width) < (u_width / 2.)) ? u_diffuseColor1 : u_diffuseColor2;

        /* Ambient Component */
        finalColor += u_ambient_color;

        highp vec3 normal = normalize(v_normal);
        highp vec3 lightDir = normalize(u_lightPosition - v_vertex);

        /* Diffuse Component */
        highp float NdotL = clamp(abs(dot(normal, lightDir)), 0.0, 1.0);
        finalColor += (NdotL * u_diffuse_color);

        /* Specular Component */
        /* TODO: We should not do specularity for fragments facing away from the light.*/
        highp vec3 reflectedLight = reflect(-lightDir, normal);
        highp vec3 viewVector = normalize(u_viewPosition - v_vertex);
        highp float NdotR = clamp(dot(viewVector, reflectedLight), 0.0, 1.0);
        finalColor += pow(NdotR, u_shininess) * u_specular_color;

        gl_FragColor = finalColor;
        gl_FragColor.a = 1.0;
    }

vertex41core =
    #version 410
    uniform highp mat4 u_modelMatrix;
    uniform highp mat4 u_viewProjectionMatrix;
    uniform highp mat4 u_normalMatrix;

    in highp vec4 a_vertex;
    in highp vec4 a_normal;
    in highp vec2 a_uvs;

    out highp vec3 v_position;
    out highp vec3 v_vertex;
    out highp vec3 v_normal;

    void main()
    {
        vec4 world_space_vert = u_modelMatrix * a_vertex;
        gl_Position = u_viewProjectionMatrix * world_space_vert;

        v_position = gl_Position.xyz;
        v_vertex = world_space_vert.xyz;
        v_normal = (u_normalMatrix * normalize(a_normal)).xyz;
    }

fragment41core =
    #version 410
    uniform mediump vec4 u_ambientColor;
    uniform mediump vec4 u_diffuseColor1;
    uniform mediump vec4 u_diffuseColor2;
    uniform mediump vec4 u_specularColor;
    uniform highp vec3 u_lightPosition;
    uniform mediump float u_shininess;
    uniform highp vec3 u_viewPosition;

    uniform mediump float u_width;

    in highp vec3 v_position;
    in highp vec3 v_vertex;
    in highp vec3 v_normal;

    out vec4 frag_color;

    void main()
    {
        mediump vec4 finalColor = vec4(0.0);
        mediump vec4 diffuseColor = (mod((-v_position.x + v_position.y), u_width) < (u_width / 2.)) ? u_diffuseColor1 : u_diffuseColor2;

        /* Ambient Component */
        finalColor += u_ambientColor;

        highp vec3 normal = normalize(v_normal);
        highp vec3 lightDir = normalize(u_lightPosition - v_vertex);

        /* Diffuse Component */
        highp float NdotL = clamp(abs(dot(normal, lightDir)), 0.0, 1.0);
        finalColor += (NdotL * diffuseColor);

        /* Specular Component */
        /* TODO: We should not do specularity for fragments facing away from the light.*/
        highp vec3 reflectedLight = reflect(-lightDir, normal);
        highp vec3 viewVector = normalize(u_viewPosition - v_vertex);
        highp float NdotR = clamp(dot(viewVector, reflectedLight), 0.0, 1.0);
        finalColor += pow(NdotR, u_shininess) * u_specularColor;

        frag_color = finalColor;
        frag_color.a = 1.0;
    }

[defaults]
u_ambient_color = [0.3, 0.3, 0.3, 1.0]
u_diffuse_color1 = [1.0, 0.5, 0.5, 1.0]
u_diffuse_color2 = [0.5, 0.5, 0.5, 1.0]
u_specular_color = [0.4, 0.4, 0.4, 1.0]
u_shininess = 20.0
u_width = 5.0

[bindings]
u_modelMatrix = model_matrix
u_viewProjectionMatrix = view_projection_matrix
u_normalMatrix = normal_matrix
u_viewPosition = view_position
u_lightPosition = light_0_position
u_diffuseColor = diffuse_color

[attributes]
a_vertex = vertex
a_normal = normal
