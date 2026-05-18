-- CreateEnum
CREATE TYPE "public"."Roles" AS ENUM ('OWNER', 'MEMBER');

-- CreateTable
CREATE TABLE "public"."Item" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "inGameId" TEXT NOT NULL,
    "slot" INTEGER NOT NULL,
    "containerId" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL,

    CONSTRAINT "Item_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."ItemDiff" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "itemId" TEXT NOT NULL,
    "diff" INTEGER NOT NULL,
    "storageSystemId" TEXT NOT NULL,

    CONSTRAINT "ItemDiff_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."StorageSystem" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "StorageSystem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Container" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "inGameId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "storageSystemId" TEXT NOT NULL,
    "slots" INTEGER NOT NULL,
    "slotsUsed" INTEGER NOT NULL,

    CONSTRAINT "Container_pkey" PRIMARY KEY ("storageSystemId","inGameId")
);

-- CreateTable
CREATE TABLE "public"."AccessPoint" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "inGameId" TEXT NOT NULL,
    "storageSystemId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "x" INTEGER NOT NULL DEFAULT 0,
    "y" INTEGER NOT NULL DEFAULT 0,
    "z" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "AccessPoint_pkey" PRIMARY KEY ("storageSystemId","inGameId")
);

-- CreateTable
CREATE TABLE "public"."User" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Member" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "userId" TEXT NOT NULL,
    "role" "public"."Roles" NOT NULL,
    "storageSystemId" TEXT NOT NULL,

    CONSTRAINT "Member_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ItemDiff_id_key" ON "public"."ItemDiff"("id");

-- CreateIndex
CREATE UNIQUE INDEX "Container_id_key" ON "public"."Container"("id");

-- CreateIndex
CREATE UNIQUE INDEX "AccessPoint_id_key" ON "public"."AccessPoint"("id");

-- AddForeignKey
ALTER TABLE "public"."Item" ADD CONSTRAINT "Item_containerId_fkey" FOREIGN KEY ("containerId") REFERENCES "public"."Container"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ItemDiff" ADD CONSTRAINT "ItemDiff_storageSystemId_fkey" FOREIGN KEY ("storageSystemId") REFERENCES "public"."StorageSystem"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Container" ADD CONSTRAINT "Container_storageSystemId_fkey" FOREIGN KEY ("storageSystemId") REFERENCES "public"."StorageSystem"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."AccessPoint" ADD CONSTRAINT "AccessPoint_storageSystemId_fkey" FOREIGN KEY ("storageSystemId") REFERENCES "public"."StorageSystem"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Member" ADD CONSTRAINT "Member_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Member" ADD CONSTRAINT "Member_storageSystemId_fkey" FOREIGN KEY ("storageSystemId") REFERENCES "public"."StorageSystem"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
