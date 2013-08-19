package com.vizar3d.ane.bullet.collision.dispatch
{
	import com.vizar3d.ane.bullet.BulletBase;
	import com.vizar3d.ane.bullet.BulletMath;
	import com.vizar3d.ane.bullet.collision.shapes.CollisionShape;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import away3d.containers.ObjectContainer3D;
	
	public class CollisionObject extends BulletBase
	{
		public static const STATIC_OBJECT: int = 1;
		public static const KINEMATIC_OBJECT: int = 2;
		public static const NO_CONTACT_RESPONSE: int = 4;
		public static const CUSTOM_MATERIAL_CALLBACK: int = 8;
		public static const CHARACTER_OBJECT: int = 16;
		public static const DISABLE_VISUALIZE_OBJECT: int = 32;
		public static const DISABLE_SPU_COLLISION_PROCESSING: int = 64;
		
		private var _skin: ObjectContainer3D;
		
		public function CollisionObject(shape:CollisionShape, skin:ObjectContainer3D, pointer:uint=0) {
			_skin = skin;
			if (!pointer) {
				this.pointer = extContext.call("createCollisionObject", shape.pointer) as uint;
				if (skin) {
					// TODO: consider whether you want the skin's transform and the CollisionObject's transform to mirror each
					// other like this, and if so, whether you want it to happen right from construction or not.
					worldTransform = skin.transform;
				}
			} else {
				this.pointer = pointer;
			}
		}
		
		public function get skin(): ObjectContainer3D {
			return _skin;
		}
		
		public function get worldTransform(): Matrix3D {
			const btTrans: Matrix3D = extContext.call("CollisionObject::getWorldTransform", pointer) as Matrix3D;
			return BulletMath.scaleTransformBulletToA3D(btTrans, btTrans);
		}
		
		public function set worldTransform(val:Matrix3D): void {
			if (skin) {
				var xform: Matrix3D = val.clone();
				if (nestedMeshes && skin.parent) {
					xform.append(skin.parent.inverseSceneTransform);
				}
				skin.transform = xform;
			}
			extContext.call("CollisionObject::setWorldTransform", pointer, BulletMath.scaleTransformA3DtoBullet(val));
		}
		
		public function get position(): Vector3D {
			return worldTransform.position;
		}
		
		public function set position(val:Vector3D): void {
			const trans: Matrix3D = worldTransform;
			trans.position = val;
			worldTransform = trans;
		}
		
		public function get collisionFlags(): int {
			return extContext.call("CollisionObject::getCollisionFlags", pointer) as int;
		}
		
		public function set collisionFlags(flags:int): void {
			extContext.call("CollisionObject::setCollisionFlags", pointer, flags);
		}
		
		public function activate(forceActivation:Boolean=false): void {
			extContext.call("CollisionObject::activate", pointer, forceActivation);
		}
	}
}