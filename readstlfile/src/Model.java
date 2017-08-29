import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class Model {

	Map<Vertex, Integer> vertexIndexMap;
	List<Face> faces;
	List<Vertex> vertexs;

	String modelName;

	static final private int InitialFaceCount = 100000;

	public Model() {
		// TODO Auto-generated constructor stub
	}

	public float readFloat(FileInputStream inputStream) throws IOException {
		byte buffer[] = new byte[4];
		inputStream.read(buffer);
		ByteBuffer byteBuffer = ByteBuffer.allocateDirect(4);
		byteBuffer.order(ByteOrder.LITTLE_ENDIAN);
		byteBuffer.put(buffer);
		byteBuffer.rewind();
		float result = byteBuffer.getFloat();
		return result;
	}

	public int readShort(FileInputStream inputStream) throws IOException {
		byte buffer[] = new byte[2];
		inputStream.read(buffer);
		return convertBytes2Integer(buffer);
	}

	public void loadModel(String path) throws FileNotFoundException,
			IOException {

		File file = new File(path);
		FileInputStream fileInputStream = new FileInputStream(file);

		// read the model string
		byte[] b = new byte[80];
		fileInputStream.read(b);
		this.modelName = new String(b);
		this.vertexIndexMap = new HashMap<Vertex, Integer>(
				InitialFaceCount / 10);
		this.faces = new ArrayList<Face>(InitialFaceCount);
		this.vertexs = new ArrayList<Vertex>(InitialFaceCount);

		// read face count
		byte integer[] = new byte[4];
		fileInputStream.read(integer);
		int faceCount = convertBytes2Integer(integer);
		System.out.println(faceCount);

		// read face and vertex
		int vertexCount = 0;
		for (int i = 0; i < faceCount; i++) {

			try {
				Face face = new Face();
				// read the face normal
				face.normalX = readFloat(fileInputStream);
				face.normalY = readFloat(fileInputStream);
				face.normalZ = readFloat(fileInputStream);

				for (int j = 0; j < 3; j++) {
					Vertex vertex = new Vertex(readFloat(fileInputStream),
							readFloat(fileInputStream),
							readFloat(fileInputStream));
					if (!vertexIndexMap.containsKey(vertex)) {
						vertexCount++;
						vertexIndexMap.put(vertex, vertexCount);
						vertexs.add(vertex);
					}
					face.vertexs.add(vertexIndexMap.get(vertex));
				}
				face.attribute = readShort(fileInputStream);
				faces.add(face);

			} catch (IOException e) {
				// TODO: handle exception
				System.out.println("not enough face");
			}
		}
	}

	public void saveModel(String path) throws IOException {
		File file = new File(path);
		FileWriter fileWriter = new FileWriter(file);
		BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);
		PrintWriter printWriter = new PrintWriter(fileWriter);
		
		printWriter.println(this.vertexs.size());
		for (int i = 0; i < this.vertexs.size(); i++) {
			String string = String.format("%s,%s,%s", vertexs.get(i).x,
					vertexs.get(i).y, vertexs.get(i).z);
			printWriter.println(string);
		}

		printWriter.println(this.faces.size());
		for (int i = 0; i < this.faces.size(); i++) {
			String string = String.format("%s,%s,%s", faces.get(i).vertexs.toArray());
			printWriter.println(string);
		}
		
		printWriter.flush();
		printWriter.close();
	}

	static public int convertBytes2Integer(byte[] bytes) {
		if (bytes == null) {
			return 0;
		}
		int result = 0;
		for (int i = 0; i < bytes.length; i++) {
			result = result * 256 + bytes[bytes.length - 1 - i];
		}
		return result;
	}

	public static void main(String[] args) throws IOException {
		Model model = new Model();
		model.loadModel("F://Dent2-.stl");
		System.out.println(model.faces.size());
		System.out.println(model.vertexIndexMap.size());
		model.saveModel("F://Dent2.dat");
	}
}
