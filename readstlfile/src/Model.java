import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Array;
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
			String string = String.format("%s,%s,%s",
					faces.get(i).vertexs.toArray());
			printWriter.println(string);
		}

		printWriter.flush();
		printWriter.close();
	}

	static public byte[] big2little(float f) {
		ByteBuffer byteBuffer = ByteBuffer.allocateDirect(4);
		byteBuffer.order(ByteOrder.LITTLE_ENDIAN);
		byteBuffer.putFloat(f);
		byteBuffer.rewind();
		byte[] arrayx = new byte[4];
		byteBuffer.get(arrayx);
		return arrayx;
	}

	static public byte[] big2little(int f) {
		ByteBuffer byteBuffer = ByteBuffer.allocateDirect(4);
		byteBuffer.order(ByteOrder.LITTLE_ENDIAN);
		byteBuffer.putInt(f);
		byteBuffer.rewind();
		byte[] arrayx = new byte[4];
		byteBuffer.get(arrayx);
		return arrayx;
	}

	static public void saveModel3(String from, String des) throws IOException {
		File file2 = new File(from);
		FileInputStream fileInputStream = new FileInputStream(file2);
		BufferedInputStream bufferedInputStream = new BufferedInputStream(
				fileInputStream);
		DataInputStream dataInputStream = new DataInputStream(
				bufferedInputStream);
		int faceCount = dataInputStream.readInt();
		float[][] floats = new float[12][faceCount];
		for (int i = 0; i < floats.length; i++) {
			for (int j = 0; j < floats[i].length; j++) {
				floats[i][j] = dataInputStream.readFloat();
			}
		}

		File file = new File(des);
		FileOutputStream fileOutputStream = new FileOutputStream(file);
		BufferedOutputStream bufferedOutputStream = new BufferedOutputStream(
				fileOutputStream);
		DataOutputStream dataOutputStream = new DataOutputStream(
				bufferedOutputStream);
		dataOutputStream.write(new byte[80]);
		dataOutputStream.write(big2little(faceCount));
		for (int i = 0; i < faceCount; i++) {
			for (int j = 0; j < 12; j++) {
				dataOutputStream.write(big2little(floats[j][i]));
			}
			dataOutputStream.writeShort(0);
		}
		dataOutputStream.flush();
		dataOutputStream.close();
	}

	public void saveModel2(String path) throws IOException {
		File file = new File(path);
		FileOutputStream fileOutputStream = new FileOutputStream(file);
		BufferedOutputStream bufferedOutputStream = new BufferedOutputStream(
				fileOutputStream);
		DataOutputStream dataOutputStream = new DataOutputStream(
				bufferedOutputStream);
		dataOutputStream.writeInt(this.vertexs.size());
		for (int i = 0; i < this.vertexs.size(); i++) {
			dataOutputStream.writeFloat(vertexs.get(i).x);
			dataOutputStream.writeFloat(vertexs.get(i).y);
			dataOutputStream.writeFloat(vertexs.get(i).z);
		}

		dataOutputStream.writeInt(this.faces.size());
		for (int i = 0; i < this.faces.size(); i++) {
			dataOutputStream.writeInt(faces.get(i).vertexs.get(0));
			dataOutputStream.writeInt(faces.get(i).vertexs.get(1));
			dataOutputStream.writeInt(faces.get(i).vertexs.get(2));
		}

		dataOutputStream.writeInt(this.faces.size());
		for (int i = 0; i < this.faces.size(); i++) {
			dataOutputStream.writeFloat(faces.get(i).normalX);
			dataOutputStream.writeFloat(faces.get(i).normalY);
			dataOutputStream.writeFloat(faces.get(i).normalZ);
		}
		dataOutputStream.flush();
		dataOutputStream.close();
	}

	static public int convertBytes2Integer(byte[] bytes) {
		if (bytes == null) {
			return 0;
		}
		int result = 0;
		ByteBuffer byteBuffer = ByteBuffer.allocateDirect(4);
		byteBuffer.order(ByteOrder.LITTLE_ENDIAN);
		byteBuffer.put(bytes);
		byteBuffer.rewind();
		result = byteBuffer.getInt();
		return result;
	}

	static public void convertFromFolder(String path)
			throws FileNotFoundException, IOException {
		File file = new File(path);
		File[] files = file.listFiles();
		if (files == null) {
			return;
		}
		for (File file2 : files) {
			if (file2.isDirectory()) {
				convertFromFolder(file2.getAbsolutePath());
			} else if (file2.getAbsolutePath().endsWith(".stl")) {
				System.out.println(file2.getAbsolutePath());
				Model model = new Model();
				model.loadModel(file2.getAbsolutePath());
				System.out.println(model.faces.size());
				System.out.println(model.vertexIndexMap.size());
				model.saveModel2(file2.getAbsolutePath().replaceAll(".stl",
						".dat"));
			}
		}
	}

	public static void main(String[] args) throws IOException {
		// convertFromFolder("/home/wangheda/Desktop/Chenhu-ModelScan");
//		File file = new File("/home/wangheda/teeth_segmentation/");
		File file = new File("C:\\Users\\think\\Documents\\MATLAB\\teeth_segmentation");
		File[] files = file.listFiles();
		if (files == null) {
			return;
		}
		int count = 1;
		for (File file2 : files) {
			if (file2.getAbsolutePath().endsWith(".tmp")) {
				System.out.println(count + ": " +file2.getAbsolutePath());
				saveModel3(file2.getAbsolutePath(), file2.getAbsolutePath()
						.replaceAll(".tmp", ".stl"));
				count ++;

			}
		}
		// Model model = new Model();
		// model.loadModel("F:\\Dent2-.stl");
		// System.out.println(model.faces.size());
		// System.out.println(model.vertexIndexMap.size());
		// model.saveModel2("F:\\Dent2.dat");
	}
}
