/// @func bbmod_mesh_to_colmesh(_mesh, _colmesh[, _transform])
/// @desc Adds a {@link BBMOD_Mesh} into a colmesh.
/// @param {BBMOD_Mesh} _mesh The mesh to add.
/// @param {colmesh} _colmesh The colmesh to add the mesh to.
/// @param {real[16]/undefined} [_transform] A matrix to transform the mesh with
/// before it is added to the colmesh. Leave `undefined` if you do not wish to
/// transform the mesh.
/// @see https://marketplace.yoyogames.com/assets/8130/colmesh
function bbmod_mesh_to_colmesh(_mesh, _colmesh, _transform=undefined)
{
	var _buffer = buffer_create_from_vertex_buffer(_mesh.VertexBuffer, buffer_fixed, 1);
	var _bufferSize = buffer_get_size(_buffer);
	var _vertexSize = _mesh.VertexFormat.get_byte_size();
	var _vertexStep = _vertexSize - 4 * 3;
	var _vertexCount = _bufferSize / _vertexSize;
	var _vertex = array_create(9, 0.0);

	buffer_copy_from_vertex_buffer(_mesh.VertexBuffer, 0, _vertexCount, _buffer, 0);
	buffer_seek(_buffer, buffer_seek_start, 0);

	repeat (_vertexCount / 3)
	{
		_vertex[0] = buffer_read(_buffer, buffer_f32);
		_vertex[1] = buffer_read(_buffer, buffer_f32);
		_vertex[2] = buffer_read(_buffer, buffer_f32);
		buffer_seek(_buffer, buffer_seek_relative, _vertexStep);

		_vertex[3] = buffer_read(_buffer, buffer_f32);
		_vertex[4] = buffer_read(_buffer, buffer_f32);
		_vertex[5] = buffer_read(_buffer, buffer_f32);
		buffer_seek(_buffer, buffer_seek_relative, _vertexStep);

		_vertex[6] = buffer_read(_buffer, buffer_f32);
		_vertex[7] = buffer_read(_buffer, buffer_f32);
		_vertex[8] = buffer_read(_buffer, buffer_f32);
		buffer_seek(_buffer, buffer_seek_relative, _vertexStep);

		if (_transform != undefined)
		{
			array_copy(_vertex, 0, colmesh_matrix_transform_vertex(_transform, _vertex[0], _vertex[1], _vertex[2]), 0, 3);
			array_copy(_vertex, 3, colmesh_matrix_transform_vertex(_transform, _vertex[3], _vertex[4], _vertex[5]), 0, 3);
			array_copy(_vertex, 6, colmesh_matrix_transform_vertex(_transform, _vertex[6], _vertex[7], _vertex[8]), 0, 3);
		}

		_colmesh.addTriangle(_vertex);
	}

	buffer_delete(_buffer);
}