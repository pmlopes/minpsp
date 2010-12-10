#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=bullet
VERSION=2.70

download build "http://bullet.googlecode.com/files" $LIBNAME-$VERSION tgz

cd build/$LIBNAME-$VERSION
cd src
make -s
install -d ../../target/psp/lib
install -d ../../target/psp/include/bullet
install -d ../../target/psp/include/bullet/BulletCollision
install -d ../../target/psp/include/bullet/BulletCollision/BroadphaseCollision
install -d ../../target/psp/include/bullet/BulletCollision/CollisionDispatch
install -d ../../target/psp/include/bullet/BulletCollision/CollisionShapes
install -d ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision
install -d ../../target/psp/include/bullet/BulletDynamics
install -d ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver
install -d ../../target/psp/include/bullet/BulletDynamics/Dynamics
install -d ../../target/psp/include/bullet/BulletDynamics/Vehicle
install -d ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver
install -d ../../target/psp/include/bullet/BulletSoftBody
install -d ../../target/psp/include/bullet/LinearMath
install -d ../../target/psp/doc/bullet
install -d ../../target/psp/sdk/samples/bullet/demo
install -d ../../target/psp/sdk/samples/bullet/demo2

install libbulletcollision.a ../../target/psp/lib
install libbulletdynamics.a ../../target/psp/lib
install libbulletmath.a ../../target/psp/lib
install libbulletsoftbody.a ../../target/psp/lib

install ./btBulletCollisionCommon.h ../../target/psp/include/bullet/btBulletCollisionCommon.h
install ./btBulletDynamicsCommon.h ../../target/psp/include/bullet/btBulletDynamicsCommon.h
install ./Bullet-C-Api.h ../../target/psp/include/bullet/Bullet-C-Api.h
install ./BulletCollision/BroadphaseCollision/btAxisSweep3.h ../../target/psp/include/bullet/BulletCollision/BroadphaseCollision/btAxisSweep3.h
install ./BulletCollision/BroadphaseCollision/btBroadphaseInterface.h ../../target/psp/include/bullet/BulletCollision/BroadphaseCollision/btBroadphaseInterface.h
install ./BulletCollision/BroadphaseCollision/btBroadphaseProxy.h ../../target/psp/include/bullet/BulletCollision/BroadphaseCollision/btBroadphaseProxy.h
install ./BulletCollision/BroadphaseCollision/btCollisionAlgorithm.h ../../target/psp/include/bullet/BulletCollision/BroadphaseCollision/btCollisionAlgorithm.h
install ./BulletCollision/BroadphaseCollision/btDbvt.h ../../target/psp/include/bullet/BulletCollision/BroadphaseCollision/btDbvt.h
install ./BulletCollision/BroadphaseCollision/btDbvtBroadphase.h ../../target/psp/include/bullet/BulletCollision/BroadphaseCollision/btDbvtBroadphase.h
install ./BulletCollision/BroadphaseCollision/btDispatcher.h ../../target/psp/include/bullet/BulletCollision/BroadphaseCollision/btDispatcher.h
install ./BulletCollision/BroadphaseCollision/btMultiSapBroadphase.h ../../target/psp/include/bullet/BulletCollision/BroadphaseCollision/btMultiSapBroadphase.h
install ./BulletCollision/BroadphaseCollision/btOverlappingPairCache.h ../../target/psp/include/bullet/BulletCollision/BroadphaseCollision/btOverlappingPairCache.h
install ./BulletCollision/BroadphaseCollision/btOverlappingPairCallback.h ../../target/psp/include/bullet/BulletCollision/BroadphaseCollision/btOverlappingPairCallback.h
install ./BulletCollision/BroadphaseCollision/btSimpleBroadphase.h ../../target/psp/include/bullet/BulletCollision/BroadphaseCollision/btSimpleBroadphase.h
install ./BulletCollision/CollisionDispatch/btBoxBoxCollisionAlgorithm.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btBoxBoxCollisionAlgorithm.h
install ./BulletCollision/CollisionDispatch/btBoxBoxDetector.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btBoxBoxDetector.h
install ./BulletCollision/CollisionDispatch/btCollisionConfiguration.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btCollisionConfiguration.h
install ./BulletCollision/CollisionDispatch/btCollisionCreateFunc.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btCollisionCreateFunc.h
install ./BulletCollision/CollisionDispatch/btCollisionDispatcher.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btCollisionDispatcher.h
install ./BulletCollision/CollisionDispatch/btCollisionObject.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btCollisionObject.h
install ./BulletCollision/CollisionDispatch/btCollisionWorld.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btCollisionWorld.h
install ./BulletCollision/CollisionDispatch/btCompoundCollisionAlgorithm.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btCompoundCollisionAlgorithm.h
install ./BulletCollision/CollisionDispatch/btConvexConcaveCollisionAlgorithm.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btConvexConcaveCollisionAlgorithm.h
install ./BulletCollision/CollisionDispatch/btConvexConvexAlgorithm.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btConvexConvexAlgorithm.h
install ./BulletCollision/CollisionDispatch/btConvexPlaneCollisionAlgorithm.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btConvexPlaneCollisionAlgorithm.h
install ./BulletCollision/CollisionDispatch/btDefaultCollisionConfiguration.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btDefaultCollisionConfiguration.h
install ./BulletCollision/CollisionDispatch/btEmptyCollisionAlgorithm.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btEmptyCollisionAlgorithm.h
install ./BulletCollision/CollisionDispatch/btManifoldResult.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btManifoldResult.h
install ./BulletCollision/CollisionDispatch/btSimulationIslandManager.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btSimulationIslandManager.h
install ./BulletCollision/CollisionDispatch/btSphereBoxCollisionAlgorithm.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btSphereBoxCollisionAlgorithm.h
install ./BulletCollision/CollisionDispatch/btSphereSphereCollisionAlgorithm.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btSphereSphereCollisionAlgorithm.h
install ./BulletCollision/CollisionDispatch/btSphereTriangleCollisionAlgorithm.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btSphereTriangleCollisionAlgorithm.h
install ./BulletCollision/CollisionDispatch/btUnionFind.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/btUnionFind.h
install ./BulletCollision/CollisionDispatch/SphereTriangleDetector.h ../../target/psp/include/bullet/BulletCollision/CollisionDispatch/SphereTriangleDetector.h
install ./BulletCollision/CollisionShapes/btBoxShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btBoxShape.h
install ./BulletCollision/CollisionShapes/btBvhTriangleMeshShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btBvhTriangleMeshShape.h
install ./BulletCollision/CollisionShapes/btCapsuleShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btCapsuleShape.h
install ./BulletCollision/CollisionShapes/btCollisionMargin.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btCollisionMargin.h
install ./BulletCollision/CollisionShapes/btCollisionShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btCollisionShape.h
install ./BulletCollision/CollisionShapes/btCompoundShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btCompoundShape.h
install ./BulletCollision/CollisionShapes/btConcaveShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btConcaveShape.h
install ./BulletCollision/CollisionShapes/btConeShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btConeShape.h
install ./BulletCollision/CollisionShapes/btConvexHullShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btConvexHullShape.h
install ./BulletCollision/CollisionShapes/btConvexInternalShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btConvexInternalShape.h
install ./BulletCollision/CollisionShapes/btConvexShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btConvexShape.h
install ./BulletCollision/CollisionShapes/btConvexTriangleMeshShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btConvexTriangleMeshShape.h
install ./BulletCollision/CollisionShapes/btCylinderShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btCylinderShape.h
install ./BulletCollision/CollisionShapes/btEmptyShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btEmptyShape.h
install ./BulletCollision/CollisionShapes/btHeightfieldTerrainShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btHeightfieldTerrainShape.h
install ./BulletCollision/CollisionShapes/btMaterial.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btMaterial.h
install ./BulletCollision/CollisionShapes/btMinkowskiSumShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btMinkowskiSumShape.h
install ./BulletCollision/CollisionShapes/btMultimaterialTriangleMeshShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btMultimaterialTriangleMeshShape.h
install ./BulletCollision/CollisionShapes/btMultiSphereShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btMultiSphereShape.h
install ./BulletCollision/CollisionShapes/btOptimizedBvh.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btOptimizedBvh.h
install ./BulletCollision/CollisionShapes/btPolyhedralConvexShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btPolyhedralConvexShape.h
install ./BulletCollision/CollisionShapes/btShapeHull.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btShapeHull.h
install ./BulletCollision/CollisionShapes/btSphereShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btSphereShape.h
install ./BulletCollision/CollisionShapes/btStaticPlaneShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btStaticPlaneShape.h
install ./BulletCollision/CollisionShapes/btStridingMeshInterface.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btStridingMeshInterface.h
install ./BulletCollision/CollisionShapes/btTetrahedronShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btTetrahedronShape.h
install ./BulletCollision/CollisionShapes/btTriangleBuffer.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btTriangleBuffer.h
install ./BulletCollision/CollisionShapes/btTriangleCallback.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btTriangleCallback.h
install ./BulletCollision/CollisionShapes/btTriangleIndexVertexArray.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btTriangleIndexVertexArray.h
install ./BulletCollision/CollisionShapes/btTriangleIndexVertexMaterialArray.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btTriangleIndexVertexMaterialArray.h
install ./BulletCollision/CollisionShapes/btTriangleMesh.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btTriangleMesh.h
install ./BulletCollision/CollisionShapes/btTriangleMeshShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btTriangleMeshShape.h
install ./BulletCollision/CollisionShapes/btTriangleShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btTriangleShape.h
install ./BulletCollision/CollisionShapes/btUniformScalingShape.h ../../target/psp/include/bullet/BulletCollision/CollisionShapes/btUniformScalingShape.h
install ./BulletCollision/NarrowPhaseCollision/btContinuousConvexCollision.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btContinuousConvexCollision.h
install ./BulletCollision/NarrowPhaseCollision/btConvexCast.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btConvexCast.h
install ./BulletCollision/NarrowPhaseCollision/btConvexPenetrationDepthSolver.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btConvexPenetrationDepthSolver.h
install ./BulletCollision/NarrowPhaseCollision/btDiscreteCollisionDetectorInterface.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btDiscreteCollisionDetectorInterface.h
install ./BulletCollision/NarrowPhaseCollision/btGjkConvexCast.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btGjkConvexCast.h
install ./BulletCollision/NarrowPhaseCollision/btGjkEpa.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btGjkEpa.h
install ./BulletCollision/NarrowPhaseCollision/btGjkEpa2.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btGjkEpa2.h
install ./BulletCollision/NarrowPhaseCollision/btGjkEpaPenetrationDepthSolver.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btGjkEpaPenetrationDepthSolver.h
install ./BulletCollision/NarrowPhaseCollision/btGjkPairDetector.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btGjkPairDetector.h
install ./BulletCollision/NarrowPhaseCollision/btManifoldPoint.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btManifoldPoint.h
install ./BulletCollision/NarrowPhaseCollision/btMinkowskiPenetrationDepthSolver.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btMinkowskiPenetrationDepthSolver.h
install ./BulletCollision/NarrowPhaseCollision/btPersistentManifold.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btPersistentManifold.h
install ./BulletCollision/NarrowPhaseCollision/btPointCollector.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btPointCollector.h
install ./BulletCollision/NarrowPhaseCollision/btRaycastCallback.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btRaycastCallback.h
install ./BulletCollision/NarrowPhaseCollision/btSimplexSolverInterface.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btSimplexSolverInterface.h
install ./BulletCollision/NarrowPhaseCollision/btSubSimplexConvexCast.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btSubSimplexConvexCast.h
install ./BulletCollision/NarrowPhaseCollision/btVoronoiSimplexSolver.h ../../target/psp/include/bullet/BulletCollision/NarrowPhaseCollision/btVoronoiSimplexSolver.h
install ./BulletDynamics/ConstraintSolver/btConeTwistConstraint.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btConeTwistConstraint.h
install ./BulletDynamics/ConstraintSolver/btConstraintSolver.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btConstraintSolver.h
install ./BulletDynamics/ConstraintSolver/btContactConstraint.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btContactConstraint.h
install ./BulletDynamics/ConstraintSolver/btContactSolverInfo.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btContactSolverInfo.h
install ./BulletDynamics/ConstraintSolver/btGeneric6DofConstraint.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btGeneric6DofConstraint.h
install ./BulletDynamics/ConstraintSolver/btHingeConstraint.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btHingeConstraint.h
install ./BulletDynamics/ConstraintSolver/btJacobianEntry.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btJacobianEntry.h
install ./BulletDynamics/ConstraintSolver/btOdeContactJoint.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btOdeContactJoint.h
install ./BulletDynamics/ConstraintSolver/btOdeJoint.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btOdeJoint.h
install ./BulletDynamics/ConstraintSolver/btOdeMacros.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btOdeMacros.h
install ./BulletDynamics/ConstraintSolver/btOdeQuickstepConstraintSolver.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btOdeQuickstepConstraintSolver.h
install ./BulletDynamics/ConstraintSolver/btOdeSolverBody.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btOdeSolverBody.h
install ./BulletDynamics/ConstraintSolver/btOdeTypedJoint.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btOdeTypedJoint.h
install ./BulletDynamics/ConstraintSolver/btPoint2PointConstraint.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btPoint2PointConstraint.h
install ./BulletDynamics/ConstraintSolver/btSequentialImpulseConstraintSolver.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btSequentialImpulseConstraintSolver.h
install ./BulletDynamics/ConstraintSolver/btSliderConstraint.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btSliderConstraint.h
install ./BulletDynamics/ConstraintSolver/btSolve2LinearConstraint.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btSolve2LinearConstraint.h
install ./BulletDynamics/ConstraintSolver/btSolverBody.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btSolverBody.h
install ./BulletDynamics/ConstraintSolver/btSolverConstraint.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btSolverConstraint.h
install ./BulletDynamics/ConstraintSolver/btSorLcp.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btSorLcp.h
install ./BulletDynamics/ConstraintSolver/btTypedConstraint.h ../../target/psp/include/bullet/BulletDynamics/ConstraintSolver/btTypedConstraint.h
install ./BulletDynamics/Dynamics/btContinuousDynamicsWorld.h ../../target/psp/include/bullet/BulletDynamics/Dynamics/btContinuousDynamicsWorld.h
install ./BulletDynamics/Dynamics/btDiscreteDynamicsWorld.h ../../target/psp/include/bullet/BulletDynamics/Dynamics/btDiscreteDynamicsWorld.h
install ./BulletDynamics/Dynamics/btDynamicsWorld.h ../../target/psp/include/bullet/BulletDynamics/Dynamics/btDynamicsWorld.h
install ./BulletDynamics/Dynamics/btRigidBody.h ../../target/psp/include/bullet/BulletDynamics/Dynamics/btRigidBody.h
install ./BulletDynamics/Dynamics/btSimpleDynamicsWorld.h ../../target/psp/include/bullet/BulletDynamics/Dynamics/btSimpleDynamicsWorld.h
install ./BulletDynamics/Vehicle/btRaycastVehicle.h ../../target/psp/include/bullet/BulletDynamics/Vehicle/btRaycastVehicle.h
install ./BulletDynamics/Vehicle/btVehicleRaycaster.h ../../target/psp/include/bullet/BulletDynamics/Vehicle/btVehicleRaycaster.h
install ./BulletDynamics/Vehicle/btWheelInfo.h ../../target/psp/include/bullet/BulletDynamics/Vehicle/btWheelInfo.h
install ./BulletSoftBody/btSoftBody.h ../../target/psp/include/bullet/BulletSoftBody/btSoftBody.h
install ./BulletSoftBody/btSoftBodyConcaveCollisionAlgorithm.h ../../target/psp/include/bullet/BulletSoftBody/btSoftBodyConcaveCollisionAlgorithm.h
install ./BulletSoftBody/btSoftBodyHelpers.h ../../target/psp/include/bullet/BulletSoftBody/btSoftBodyHelpers.h
install ./BulletSoftBody/btSoftBodyInternals.h ../../target/psp/include/bullet/BulletSoftBody/btSoftBodyInternals.h
install ./BulletSoftBody/btSoftBodyRigidBodyCollisionConfiguration.h ../../target/psp/include/bullet/BulletSoftBody/btSoftBodyRigidBodyCollisionConfiguration.h
install ./BulletSoftBody/btSoftRigidCollisionAlgorithm.h ../../target/psp/include/bullet/BulletSoftBody/btSoftRigidCollisionAlgorithm.h
install ./BulletSoftBody/btSoftRigidDynamicsWorld.h ../../target/psp/include/bullet/BulletSoftBody/btSoftRigidDynamicsWorld.h
install ./BulletSoftBody/btSoftSoftCollisionAlgorithm.h ../../target/psp/include/bullet/BulletSoftBody/btSoftSoftCollisionAlgorithm.h
install ./BulletSoftBody/btSparseSDF.h ../../target/psp/include/bullet/BulletSoftBody/btSparseSDF.h
install ./LinearMath/btAabbUtil2.h ../../target/psp/include/bullet/LinearMath/btAabbUtil2.h
install ./LinearMath/btAlignedAllocator.h ../../target/psp/include/bullet/LinearMath/btAlignedAllocator.h
install ./LinearMath/btAlignedObjectArray.h ../../target/psp/include/bullet/LinearMath/btAlignedObjectArray.h
install ./LinearMath/btConvexHull.h ../../target/psp/include/bullet/LinearMath/btConvexHull.h
install ./LinearMath/btDefaultMotionState.h ../../target/psp/include/bullet/LinearMath/btDefaultMotionState.h
install ./LinearMath/btGeometryUtil.h ../../target/psp/include/bullet/LinearMath/btGeometryUtil.h
install ./LinearMath/btHashMap.h ../../target/psp/include/bullet/LinearMath/btHashMap.h
install ./LinearMath/btIDebugDraw.h ../../target/psp/include/bullet/LinearMath/btIDebugDraw.h
install ./LinearMath/btList.h ../../target/psp/include/bullet/LinearMath/btList.h
install ./LinearMath/btMatrix3x3.h ../../target/psp/include/bullet/LinearMath/btMatrix3x3.h
install ./LinearMath/btMinMax.h ../../target/psp/include/bullet/LinearMath/btMinMax.h
install ./LinearMath/btMotionState.h ../../target/psp/include/bullet/LinearMath/btMotionState.h
install ./LinearMath/btPoint3.h ../../target/psp/include/bullet/LinearMath/btPoint3.h
install ./LinearMath/btPoolAllocator.h ../../target/psp/include/bullet/LinearMath/btPoolAllocator.h
install ./LinearMath/btQuadWord.h ../../target/psp/include/bullet/LinearMath/btQuadWord.h
install ./LinearMath/btQuaternion.h ../../target/psp/include/bullet/LinearMath/btQuaternion.h
install ./LinearMath/btQuickprof.h ../../target/psp/include/bullet/LinearMath/btQuickprof.h
install ./LinearMath/btRandom.h ../../target/psp/include/bullet/LinearMath/btRandom.h
install ./LinearMath/btScalar.h ../../target/psp/include/bullet/LinearMath/btScalar.h
install ./LinearMath/btStackAlloc.h ../../target/psp/include/bullet/LinearMath/btStackAlloc.h
install ./LinearMath/btTransform.h ../../target/psp/include/bullet/LinearMath/btTransform.h
install ./LinearMath/btTransformUtil.h ../../target/psp/include/bullet/LinearMath/btTransformUtil.h
install ./LinearMath/btVector3.h ../../target/psp/include/bullet/LinearMath/btVector3.h

install ../Bullet_Faq.pdf ../../target/psp/doc/bullet/Bullet_Faq.pdf
install ../Bullet_User_Manual.pdf ../../target/psp/doc/bullet/Bullet_User_Manual.pdf
install ../BulletSpuOptimized.pdf ../../target/psp/doc/bullet/BulletSpuOptimized.pdf

install ../../../demo/CTimer.cpp ../../target/psp/sdk/samples/bullet/demo/CTimer.cpp
install ../../../demo/CTimer.h ../../target/psp/sdk/samples/bullet/demo/CTimer.h
install ../../../demo/main.cpp ../../target/psp/sdk/samples/bullet/demo/main.cpp
install ../../../demo/main.h ../../target/psp/sdk/samples/bullet/demo/main.h
install ../../../demo/Render.cpp ../../target/psp/sdk/samples/bullet/demo/Render.cpp
install ../../../demo/Render.h ../../target/psp/sdk/samples/bullet/demo/Render.h
install ../../../demo/vram.c ../../target/psp/sdk/samples/bullet/demo/vram.c
install ../../../demo/vram.h ../../target/psp/sdk/samples/bullet/demo/vram.h
install ../../../demo/Makefile ../../target/psp/sdk/samples/bullet/demo/Makefile

install ../../../demo2/CTimer.cpp ../../target/psp/sdk/samples/bullet/demo2/CTimer.cpp
install ../../../demo2/CTimer.h ../../target/psp/sdk/samples/bullet/demo2/CTimer.h
install ../../../demo2/main.cpp ../../target/psp/sdk/samples/bullet/demo2/main.cpp
install ../../../demo2/main.h ../../target/psp/sdk/samples/bullet/demo2/main.h
install ../../../demo2/Render.cpp ../../target/psp/sdk/samples/bullet/demo2/Render.cpp
install ../../../demo2/Render.h ../../target/psp/sdk/samples/bullet/demo2/Render.h
install ../../../demo2/vram.c ../../target/psp/sdk/samples/bullet/demo2/vram.c
install ../../../demo2/vram.h ../../target/psp/sdk/samples/bullet/demo2/vram.h
install ../../../demo2/Makefile ../../target/psp/sdk/samples/bullet/demo2/Makefile

cd ../../..

makeInstaller $LIBNAME $VERSION

echo "Done!"

